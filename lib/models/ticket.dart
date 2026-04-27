import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum TicketStatus {
  waiting,
  called,
  done;

  String get label => switch (this) {
        TicketStatus.waiting => 'Menunggu',
        TicketStatus.called => 'Dipanggil',
        TicketStatus.done => 'Selesai',
      };

  static TicketStatus fromName(String? name) =>
      TicketStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => TicketStatus.waiting,
      );
}

class Ticket extends Equatable {
  final String id;
  final String number;
  final int sequenceNumber;
  final String serviceId;
  final String? counterId;
  final TicketStatus status;
  final int skipCount;
  final int recallCount;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? queuedAt;
  final DateTime? calledAt;
  final DateTime? doneAt;

  const Ticket({
    required this.id,
    required this.number,
    required this.sequenceNumber,
    required this.serviceId,
    this.counterId,
    this.status = TicketStatus.waiting,
    this.skipCount = 0,
    this.recallCount = 0,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.createdAt,
    this.queuedAt,
    this.calledAt,
    this.doneAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'number': number,
        'sequenceNumber': sequenceNumber,
        'serviceId': serviceId,
        'counterId': counterId,
        'status': status.name,
        'skipCount': skipCount,
        'recallCount': recallCount,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'notes': notes,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
        if (queuedAt != null) 'queuedAt': Timestamp.fromDate(queuedAt!),
        if (calledAt != null) 'calledAt': Timestamp.fromDate(calledAt!),
        if (doneAt != null) 'doneAt': Timestamp.fromDate(doneAt!),
      };

  factory Ticket.fromMap(Map<String, dynamic> map) {
    DateTime? readDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return null;
    }

    return Ticket(
      id: map['id']?.toString() ?? '',
      number: map['number']?.toString() ?? '',
      sequenceNumber: (map['sequenceNumber'] as num?)?.toInt() ?? 0,
      serviceId: map['serviceId']?.toString() ?? '',
      counterId: map['counterId']?.toString(),
      status: TicketStatus.fromName(map['status']?.toString()),
      skipCount: (map['skipCount'] as num?)?.toInt() ?? 0,
      recallCount: (map['recallCount'] as num?)?.toInt() ?? 0,
      customerName: map['customerName']?.toString(),
      customerPhone: map['customerPhone']?.toString(),
      notes: map['notes']?.toString(),
      createdAt: readDate(map['createdAt']),
      queuedAt: readDate(map['queuedAt']),
      calledAt: readDate(map['calledAt']),
      doneAt: readDate(map['doneAt']),
    );
  }

  @override
  List<Object?> get props => [id];
}
