import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/counter.dart';
import '../models/service.dart';
import '../models/zone.dart';

/// In-memory cache of small relation collections so flutter_filament's
/// synchronous `Select.options` can be built without an extra async hop.
///
/// Subscribed to Firestore `snapshots()` once at app start; reads are sync.
class LookupCache {
  LookupCache._();
  static final LookupCache instance = LookupCache._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Zone> zones = const [];
  List<Service> services = const [];
  List<Counter> counters = const [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _zonesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _servicesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _countersSub;

  Future<void> init() async {
    final zonesCol = _firestore.collection('zones');
    final servicesCol = _firestore.collection('services');
    final countersCol = _firestore.collection('counters');

    final results = await Future.wait([
      zonesCol.get(),
      servicesCol.get(),
      countersCol.get(),
    ]);
    zones = results[0]
        .docs
        .map((d) => Zone.fromMap({...d.data(), 'id': d.id}))
        .toList();
    services = results[1]
        .docs
        .map((d) => Service.fromMap({...d.data(), 'id': d.id}))
        .toList();
    counters = results[2]
        .docs
        .map((d) => Counter.fromMap({...d.data(), 'id': d.id}))
        .toList();

    _zonesSub = zonesCol.snapshots().listen((snap) {
      zones = snap.docs
          .map((d) => Zone.fromMap({...d.data(), 'id': d.id}))
          .toList();
    });
    _servicesSub = servicesCol.snapshots().listen((snap) {
      services = snap.docs
          .map((d) => Service.fromMap({...d.data(), 'id': d.id}))
          .toList();
    });
    _countersSub = countersCol.snapshots().listen((snap) {
      counters = snap.docs
          .map((d) => Counter.fromMap({...d.data(), 'id': d.id}))
          .toList();
    });
  }

  String zoneName(String? id) =>
      zones.where((z) => z.id == id).map((z) => z.name).firstOrNull ?? '-';

  String serviceName(String? id) => services
      .where((s) => s.id == id)
      .map((s) => s.name)
      .firstOrNull ??
      '-';

  String counterName(String? id) => counters
      .where((c) => c.id == id)
      .map((c) => c.name)
      .firstOrNull ??
      '-';

  Future<void> dispose() async {
    await _zonesSub?.cancel();
    await _servicesSub?.cancel();
    await _countersSub?.cancel();
  }
}
