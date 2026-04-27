import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ai_voice_settings.dart';

/// Akses pengaturan Voice AI di `app_settings/ai_voice`. Singleton.
class AiVoiceSettingsService {
  AiVoiceSettingsService._();
  static final instance = AiVoiceSettingsService._();

  static const _collection = 'app_settings';

  DocumentReference<Map<String, dynamic>> get _ref => FirebaseFirestore.instance
      .collection(_collection)
      .doc(AiVoiceSettings.docId);

  AiVoiceSettings _current = const AiVoiceSettings();

  /// Snapshot terakhir yang dibaca. Sinkron — siap dibaca dari kode UI.
  AiVoiceSettings get current => _current;

  /// Stream perubahan settings — kalau admin ubah di panel, kios langsung
  /// dapat update tanpa restart.
  Stream<AiVoiceSettings> watch() => _ref.snapshots().map((snap) {
        final data = snap.exists
            ? AiVoiceSettings.fromMap({...?snap.data(), 'id': snap.id})
            : const AiVoiceSettings();
        _current = data;
        return data;
      });

  Future<AiVoiceSettings> read() async {
    final snap = await _ref.get();
    final data = snap.exists
        ? AiVoiceSettings.fromMap({...?snap.data(), 'id': snap.id})
        : const AiVoiceSettings();
    _current = data;
    return data;
  }

  /// Pastikan dokumen ada dengan default. Dipanggil sekali di app startup
  /// — supaya admin tidak harus klik "Buat" dulu sebelum bisa edit.
  Future<void> ensureExists() async {
    final snap = await _ref.get();
    if (snap.exists) {
      _current = AiVoiceSettings.fromMap({...?snap.data(), 'id': snap.id});
      return;
    }
    const defaults = AiVoiceSettings();
    await _ref.set({
      ...defaults.toMap()..remove('id'),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _current = defaults;
  }
}
