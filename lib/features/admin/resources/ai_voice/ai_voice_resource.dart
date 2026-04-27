import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../data/firestore_data_source.dart';
import '../../../../models/ai_voice_settings.dart';
import 'pages/edit_ai_voice.dart';
import 'pages/list_ai_voice.dart';

final aiVoiceDataSource = FirestoreDataSource<AiVoiceSettings>(
  collection: FirebaseFirestore.instance.collection('app_settings'),
  fromMap: AiVoiceSettings.fromMap,
  toMap: (s) => s.toMap(),
  idOf: (s) => s.id,
);

/// Resource singleton untuk pengaturan Voice AI. Hanya ada satu dokumen
/// (`app_settings/ai_voice`) yang di-init saat startup. Admin hanya bisa
/// edit — tidak ada Create / Delete.
class AiVoiceResource extends Resource<AiVoiceSettings> {
  @override
  String get slug => 'ai-voice';
  @override
  String get label => 'Voice AI';
  @override
  String get pluralLabel => 'Voice AI';
  @override
  IconData get icon => Icons.record_voice_over_outlined;
  @override
  String? get navigationGroup => 'Pengaturan';
  @override
  int get navigationSort => 100;

  @override
  DataSource<AiVoiceSettings> get dataSource => aiVoiceDataSource;

  @override
  String recordId(AiVoiceSettings r) => r.id;
  @override
  String recordTitle(AiVoiceSettings r) => 'Voice AI';
  @override
  Map<String, dynamic> toFormData(AiVoiceSettings r) => r.toMap();

  @override
  FormSchema form(ResourceContext<AiVoiceSettings> ctx) => FormSchema(
        columns: 2,
        components: [
          Toggle(
            name: 'enabled',
            label: 'Aktifkan Voice AI',
            helperText:
                'Master switch global. Bisa di-override per kios di form Kios.',
            defaultValue: false,
            columnSpan: 2,
          ),
          TextInput(
            name: 'apiKey',
            label: 'API Key',
            placeholder: 'sk-ant-…',
            required: true,
            helperText:
                'Disimpan plaintext di Firestore — pastikan rule Firestore '
                'membatasi akses ke admin saja. Rotate kalau bocor.',
            columnSpan: 2,
          ),
          TextInput(
            name: 'model',
            label: 'Model',
            defaultValue: 'claude-haiku-4-5',
            helperText: 'Mis. `claude-haiku-4-5` (cepat & murah, default) '
                'atau `claude-sonnet-4-6` (lebih akurat tapi ~5x mahal).',
            columnSpan: 2,
          ),
          Textarea(
            name: 'systemPromptExtra',
            label: 'System Prompt Tambahan',
            rows: 4,
            placeholder:
                'Mis. "Selalu sebut nama instansi \'Kelurahan Mawar\' '
                'di sapaan." atau "Gunakan bahasa formal."',
            helperText:
                'Opsional. Disambung ke prompt default. Kosongkan untuk pakai '
                'default saja.',
            columnSpan: 2,
          ),
        ],
      );

  @override
  Map<String, ResourcePage<AiVoiceSettings>> pages() => {
        'index': ListAiVoice.route(),
        'edit': EditAiVoice.route(),
      };

  @override
  TableSchema<AiVoiceSettings> table() => TableSchema<AiVoiceSettings>(
        columns: [
          TextColumn<AiVoiceSettings>(
            name: 'label',
            label: 'Pengaturan',
            accessor: (_) => 'Voice AI',
            bold: true,
          ),
          BooleanColumn<AiVoiceSettings>(
            name: 'enabled',
            label: 'Aktif',
            accessor: (r) => r.enabled,
          ),
          TextColumn<AiVoiceSettings>(
            name: 'model',
            label: 'Model',
            accessor: (r) => r.model,
          ),
        ],
        rowActions: const [],
      );
}
