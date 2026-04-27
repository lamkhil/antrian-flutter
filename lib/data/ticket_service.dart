import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/service.dart';
import '../models/ticket.dart';
import 'lookup_cache.dart';

/// Operations on the `tickets` collection. Numbering uses a per-service,
/// per-day counter doc updated transactionally. State machine:
/// `waiting → called → done` (skip pushes called→waiting; transfer changes
/// counterId without leaving `called`).
class TicketService {
  final FirebaseFirestore _firestore;
  TicketService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tickets =>
      _firestore.collection('tickets');
  CollectionReference<Map<String, dynamic>> _dailyCounters(String serviceId) =>
      _firestore
          .collection('services')
          .doc(serviceId)
          .collection('dailyCounters');

  static String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  static DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String _serviceCode(Service s) {
    final code = (s.code ?? '').trim();
    if (code.isNotEmpty) return code.toUpperCase();
    return s.name.isEmpty ? '#' : s.name.substring(0, 1).toUpperCase();
  }

  /// Issues a new waiting ticket. Used by the kiosk client (and dev tooling).
  Future<Ticket> createTicket(String serviceId) async {
    final service = LookupCache.instance.services
        .where((s) => s.id == serviceId)
        .firstOrNull;
    if (service == null) {
      throw StateError('Layanan $serviceId tidak ditemukan');
    }
    final code = _serviceCode(service);
    final counterRef = _dailyCounters(serviceId).doc(_todayKey());
    final ticketRef = _tickets.doc();

    return _firestore.runTransaction<Ticket>((tx) async {
      final snap = await tx.get(counterRef);
      final current = (snap.data()?['next'] as num?)?.toInt() ?? 0;
      final next = current + 1;
      final number = '$code-${next.toString().padLeft(3, '0')}';

      tx.set(counterRef, {
        'next': next,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.set(ticketRef, {
        'number': number,
        'sequenceNumber': next,
        'serviceId': serviceId,
        'status': TicketStatus.waiting.name,
        'skipCount': 0,
        'recallCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'queuedAt': FieldValue.serverTimestamp(),
      });

      final now = DateTime.now();
      return Ticket(
        id: ticketRef.id,
        number: number,
        sequenceNumber: next,
        serviceId: serviceId,
        status: TicketStatus.waiting,
        createdAt: now,
        queuedAt: now,
      );
    });
  }

  /// Live stream of today's tickets for the given counter's services.
  /// Sorted client-side: called-by-this-counter first, then waiting by queuedAt.
  Stream<List<Ticket>> streamTodayTickets({
    required String counterId,
    required List<String> serviceIds,
  }) {
    if (serviceIds.isEmpty) return Stream.value(const []);
    final start = Timestamp.fromDate(_startOfToday());
    return _tickets
        .where('serviceId', whereIn: serviceIds.take(30).toList())
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => Ticket.fromMap({...d.data(), 'id': d.id}))
          .where((t) {
        if (t.status == TicketStatus.done ||
            t.status == TicketStatus.cancelled) {
          return false;
        }
        if (t.status == TicketStatus.called) return t.counterId == counterId;
        return true;
      }).toList();
      list.sort((a, b) {
        if (a.status != b.status) {
          if (a.status == TicketStatus.called) return -1;
          if (b.status == TicketStatus.called) return 1;
        }
        final aQ = a.queuedAt ?? a.createdAt ?? DateTime(2000);
        final bQ = b.queuedAt ?? b.createdAt ?? DateTime(2000);
        return aQ.compareTo(bQ);
      });
      return list;
    });
  }

  /// Live stream of tickets with status `done` / `cancelled` pada tanggal
  /// [date], terbatas ke [serviceIds] yang ditangani loket. Sort: paling
  /// baru selesai/dibuang di atas. Dipakai tab "Riwayat" di counter page.
  Stream<List<Ticket>> streamHistory({
    required List<String> serviceIds,
    required DateTime date,
  }) {
    if (serviceIds.isEmpty) return Stream.value(const []);
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _tickets
        .where('serviceId', whereIn: serviceIds.take(30).toList())
        .where('doneAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('doneAt', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => Ticket.fromMap({...d.data(), 'id': d.id}))
          .where((t) =>
              t.status == TicketStatus.done ||
              t.status == TicketStatus.cancelled)
          .toList();
      list.sort((a, b) {
        final aD = a.doneAt ?? a.createdAt ?? DateTime(2000);
        final bD = b.doneAt ?? b.createdAt ?? DateTime(2000);
        return bD.compareTo(aD);
      });
      return list;
    });
  }

  /// Picks the oldest waiting ticket whose service is served by [counterId]
  /// and marks it called. Returns null if none are waiting.
  Future<Ticket?> callNext({
    required String counterId,
    required List<String> serviceIds,
  }) async {
    if (serviceIds.isEmpty) return null;
    final start = Timestamp.fromDate(_startOfToday());
    final query = await _tickets
        .where('status', isEqualTo: TicketStatus.waiting.name)
        .where('serviceId', whereIn: serviceIds.take(30).toList())
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .orderBy('createdAt')
        .orderBy('queuedAt')
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final docRef = query.docs.first.reference;

    return _firestore.runTransaction<Ticket?>((tx) async {
      final snap = await tx.get(docRef);
      final data = snap.data();
      if (data == null) return null;
      if (data['status'] != TicketStatus.waiting.name) return null;
      tx.update(docRef, {
        'status': TicketStatus.called.name,
        'counterId': counterId,
        'calledAt': FieldValue.serverTimestamp(),
      });
      return Ticket.fromMap({
        ...data,
        'id': snap.id,
        'status': TicketStatus.called.name,
        'counterId': counterId,
        'calledAt': DateTime.now(),
      });
    });
  }

  /// Skip the currently-called ticket: send back to the end of the waiting
  /// queue and clear counterId. Increments skipCount.
  Future<void> skip(String ticketId) async {
    await _tickets.doc(ticketId).update({
      'status': TicketStatus.waiting.name,
      'counterId': null,
      'calledAt': null,
      'queuedAt': FieldValue.serverTimestamp(),
      'skipCount': FieldValue.increment(1),
    });
  }

  /// Buang tiket — tidak dihapus, hanya tidak bisa dipanggil ulang.
  /// Status dipindah ke [TicketStatus.cancelled] supaya tetap ke-record
  /// di Firestore (untuk reporting / audit) tapi otomatis hilang dari
  /// stream operator dan display.
  Future<void> cancel(String ticketId) async {
    await _tickets.doc(ticketId).update({
      'status': TicketStatus.cancelled.name,
      'counterId': null,
      'calledAt': null,
      'doneAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark the ticket as served. Customer info captured at this step.
  Future<void> serve({
    required String ticketId,
    String? customerName,
    String? customerPhone,
    String? notes,
  }) async {
    await _tickets.doc(ticketId).update({
      'status': TicketStatus.done.name,
      'doneAt': FieldValue.serverTimestamp(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'notes': notes,
    });
  }

  /// No DB state change beyond a recallCount bump (useful for analytics).
  /// The actual TTS / display refresh is the caller's job.
  Future<void> recall(String ticketId) async {
    await _tickets.doc(ticketId).update({
      'recallCount': FieldValue.increment(1),
    });
  }

  /// Hand the ticket over to another counter. Stays in `called` state.
  Future<void> transfer({
    required String ticketId,
    required String targetCounterId,
  }) async {
    await _tickets.doc(ticketId).update({
      'counterId': targetCounterId,
      'calledAt': FieldValue.serverTimestamp(),
    });
  }
}
