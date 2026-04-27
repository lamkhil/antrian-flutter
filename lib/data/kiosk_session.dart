import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/kiosk.dart';

/// Per-device kiosk identity. The first time the kiosk app launches on a
/// device, the operator types in the deviceId issued by an admin (Kios menu);
/// it's persisted in SharedPreferences and looked up against the `kiosks`
/// Firestore collection on every cold start to confirm it's still active.
class KioskSession {
  KioskSession._();
  static final KioskSession instance = KioskSession._();

  static const _prefKey = 'kiosk_device_id';

  String? _deviceId;
  Kiosk? _kiosk;

  String? get deviceId => _deviceId;
  Kiosk? get kiosk => _kiosk;

  Future<String?> loadDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString(_prefKey);
    return _deviceId;
  }

  /// Looks up the deviceId in Firestore. Returns the Kiosk record if found
  /// and active; returns null otherwise.
  Future<Kiosk?> resolve(String deviceId) async {
    final snap = await FirebaseFirestore.instance
        .collection('kiosks')
        .where('deviceId', isEqualTo: deviceId.trim())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    final kiosk = Kiosk.fromMap({...doc.data(), 'id': doc.id});
    if (!kiosk.active) return null;
    _kiosk = kiosk;
    return kiosk;
  }

  Future<void> saveDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, deviceId.trim());
    _deviceId = deviceId.trim();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    _deviceId = null;
    _kiosk = null;
  }
}
