import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Pengaturan global Voice AI. Singleton — disimpan di
/// `app_settings/ai_voice`. Disetel dari admin panel.
class AiVoiceSettings extends Equatable {
  /// ID tetap dokumen Firestore.
  static const docId = 'ai_voice';

  final String id;

  /// Master switch global. Kalau `false`, semua kios mati voice mode-nya
  /// (kecuali kios yang punya override `forceOn`).
  final bool enabled;

  /// Provider LLM. Saat ini hanya `'anthropic'`.
  final String provider;

  /// API key untuk provider. Disimpan plaintext di Firestore.
  final String apiKey;

  /// Nama model, mis. `claude-haiku-4-5` atau `claude-sonnet-4-6`.
  final String model;

  /// Tambahan custom untuk system prompt — disambung ke prompt default
  /// di belakang. Berguna untuk tone, brand voice, atau aturan khusus
  /// (mis. "Selalu sebut nama instansi 'Kelurahan Mawar' di sapaan").
  final String? systemPromptExtra;

  final DateTime? updatedAt;

  const AiVoiceSettings({
    this.id = docId,
    this.enabled = false,
    this.provider = 'anthropic',
    this.apiKey = '',
    this.model = 'claude-haiku-4-5',
    this.systemPromptExtra,
    this.updatedAt,
  });

  AiVoiceSettings copyWith({
    bool? enabled,
    String? provider,
    String? apiKey,
    String? model,
    String? systemPromptExtra,
    DateTime? updatedAt,
  }) =>
      AiVoiceSettings(
        id: id,
        enabled: enabled ?? this.enabled,
        provider: provider ?? this.provider,
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
        systemPromptExtra: systemPromptExtra ?? this.systemPromptExtra,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'enabled': enabled,
        'provider': provider,
        'apiKey': apiKey,
        'model': model,
        'systemPromptExtra': systemPromptExtra,
        if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      };

  factory AiVoiceSettings.fromMap(Map<String, dynamic> map) {
    final raw = map['updatedAt'];
    DateTime? updated;
    if (raw is Timestamp) updated = raw.toDate();
    if (raw is DateTime) updated = raw;
    String? str(String key) {
      final v = map[key];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return AiVoiceSettings(
      id: map['id']?.toString() ?? docId,
      enabled: map['enabled'] as bool? ?? false,
      provider: map['provider']?.toString() ?? 'anthropic',
      apiKey: map['apiKey']?.toString() ?? '',
      model: map['model']?.toString() ?? 'claude-haiku-4-5',
      systemPromptExtra: str('systemPromptExtra'),
      updatedAt: updated,
    );
  }

  @override
  List<Object?> get props => [id];
}
