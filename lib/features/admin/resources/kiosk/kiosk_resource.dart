import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../data/firestore_data_source.dart';
import '../../../../models/kiosk.dart';
import 'pages/create_kiosk.dart';
import 'pages/edit_kiosk.dart';
import 'pages/list_kiosks.dart';
import 'pages/view_kiosk.dart';

final kioskDataSource = FirestoreDataSource<Kiosk>(
  collection: FirebaseFirestore.instance.collection('kiosks'),
  fromMap: Kiosk.fromMap,
  toMap: (k) => k.toMap(),
  idOf: (k) => k.id,
);

class KioskResource extends Resource<Kiosk> {
  @override
  String get slug => 'kiosks';
  @override
  String get label => 'Kios';
  @override
  String get pluralLabel => 'Kios';
  @override
  IconData get icon => Icons.print_outlined;
  @override
  String? get navigationGroup => 'Perangkat';
  @override
  int get navigationSort => 10;

  @override
  DataSource<Kiosk> get dataSource => kioskDataSource;

  @override
  String recordId(Kiosk r) => r.id;
  @override
  String recordTitle(Kiosk r) => r.name;
  @override
  Map<String, dynamic> toFormData(Kiosk r) => r.toMap();

  @override
  FormSchema form(ResourceContext<Kiosk> ctx) => FormSchema(
        columns: 2,
        components: [
          TextInput(
            name: 'name',
            label: 'Nama Kios',
            required: true,
            columnSpan: 2,
          ),
          TextInput(
            name: 'deviceId',
            label: 'Device ID',
            required: true,
            helperText:
                'Diisi otomatis oleh perangkat kios saat pertama kali dibuka.',
          ),
          Toggle(name: 'active', label: 'Aktif', defaultValue: true),
          Section(
            title: 'Tampilan Kios',
            description:
                'Atur latar belakang dan warna aksen halaman kios. Default mengikuti tema login.',
            columns: 2,
            children: [
              Select<String>(
                name: 'bgType',
                label: 'Tipe Latar Belakang',
                defaultValue: KioskBgType.gradient.name,
                columnSpan: 2,
                options: KioskBgType.values
                    .map((t) => SelectOption<String>(t.name, t.label))
                    .toList(),
              ),
              TextInput(
                name: 'bgColor',
                label: 'Warna Latar (hex)',
                placeholder: '#0D0A2E',
                helperText: 'Gunakan format hex 6 digit, mis. `#0D0A2E`.',
                columnSpan: 2,
                visibleWhen: (s) => s.get('bgType') == KioskBgType.color.name,
              ),
              TextInput(
                name: 'bgImageUrl',
                label: 'URL Gambar Latar',
                placeholder: 'https://…',
                helperText:
                    'URL gambar publik (HTTPS). Idealnya min. 1080×1920 untuk layar potret.',
                columnSpan: 2,
                visibleWhen: (s) => s.get('bgType') == KioskBgType.image.name,
              ),
              TextInput(
                name: 'buttonColor',
                label: 'Warna Aksen Tombol (hex)',
                placeholder: '#6366F1',
                helperText:
                    'Kosongkan untuk pakai indigo default. Format `#RRGGBB`.',
                columnSpan: 2,
              ),
            ],
          ),
          Section(
            title: 'Branding Tiket Cetak',
            description:
                'Header & footer yang dicetak di tiket. Berlaku untuk semua '
                'transport printer (Bluetooth, printer sistem, dialog browser).',
            columns: 2,
            children: [
              TextInput(
                name: 'printLogoUrl',
                label: 'URL Logo',
                placeholder: 'https://…',
                helperText:
                    'PNG/JPG publik (HTTPS). Untuk printer thermal idealnya '
                    'monokrom kontras tinggi (mis. logo hitam latar putih).',
                columnSpan: 2,
              ),
              TextInput(
                name: 'printCompanyName',
                label: 'Nama Perusahaan',
                placeholder: 'PT Contoh Indonesia',
                columnSpan: 2,
              ),
              TextInput(
                name: 'printCompanySubtitle',
                label: 'Sub-judul / Cabang',
                placeholder: 'Cabang Lobi Utama',
                columnSpan: 2,
              ),
              Textarea(
                name: 'printHeaderText',
                label: 'Header Tambahan',
                rows: 3,
                placeholder: 'Jl. Contoh No. 123\nTelp: 021-12345678',
                helperText: 'Multi-baris. Dicetak di bawah nama perusahaan.',
                columnSpan: 2,
              ),
              Textarea(
                name: 'printFooterText',
                label: 'Footer',
                rows: 3,
                placeholder: 'Terima kasih atas kunjungan Anda.\n'
                    'Mohon menunggu giliran panggilan.',
                helperText:
                    'Multi-baris. Dicetak di bagian bawah tiket. Kosongkan '
                    'untuk pakai pesan default.',
                columnSpan: 2,
              ),
            ],
          ),
          Section(
            title: 'Voice AI',
            description:
                'Override mode Voice AI untuk kios ini. `Ikut Global` = '
                'mengikuti master switch di Pengaturan > Voice AI. Pakai '
                '`Paksa Nonaktif` untuk kios di area bising, atau '
                '`Paksa Aktif` untuk uji coba di kios tertentu.',
            columns: 2,
            children: [
              Select<String>(
                name: 'aiVoiceMode',
                label: 'Mode Voice AI',
                defaultValue: KioskAiVoiceMode.auto.name,
                columnSpan: 2,
                options: KioskAiVoiceMode.values
                    .map((m) => SelectOption<String>(m.name, m.label))
                    .toList(),
              ),
            ],
          ),
        ],
      );

  @override
  Map<String, ResourcePage<Kiosk>> pages() => {
        'index': ListKiosks.route(),
        'create': CreateKiosk.route(),
        'view': ViewKiosk.route(),
        'edit': EditKiosk.route(),
      };

  @override
  TableSchema<Kiosk> table() => TableSchema<Kiosk>(
        defaultSort: 'name',
        columns: [
          TextColumn<Kiosk>(
            name: 'name',
            label: 'Nama',
            accessor: (r) => r.name,
            searchable: true,
            sortable: true,
            bold: true,
          ),
          TextColumn<Kiosk>(
            name: 'deviceId',
            label: 'Device ID',
            accessor: (r) => r.deviceId,
            searchable: true,
          ),
          BooleanColumn<Kiosk>(
            name: 'active',
            label: 'Aktif',
            accessor: (r) => r.active,
          ),
        ],
        rowActions: [
          RowAction.delete<Kiosk>((ctx, row) async {
            await kioskDataSource.delete(row.id);
          }),
        ],
      );
}
