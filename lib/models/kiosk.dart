import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum KioskBgType {
  gradient,
  color,
  image;

  String get label => switch (this) {
        KioskBgType.gradient => 'Gradien Default (tema login)',
        KioskBgType.color => 'Warna solid',
        KioskBgType.image => 'Gambar',
      };

  static KioskBgType fromName(String? name) =>
      KioskBgType.values.firstWhere(
        (t) => t.name == name,
        orElse: () => KioskBgType.gradient,
      );
}

/// Override per-kios untuk fitur Voice AI. `auto` ikut master switch
/// global di `AiVoiceSettings.enabled`. `forceOn`/`forceOff` mengabaikan
/// global — berguna untuk matikan voice di kios area bising tanpa
/// matikan global, atau menyalakan di kios khusus saja saat uji coba.
enum KioskAiVoiceMode {
  auto,
  forceOn,
  forceOff;

  String get label => switch (this) {
        KioskAiVoiceMode.auto => 'Ikut Pengaturan Global',
        KioskAiVoiceMode.forceOn => 'Paksa Aktif',
        KioskAiVoiceMode.forceOff => 'Paksa Nonaktif',
      };

  static KioskAiVoiceMode fromName(String? name) =>
      KioskAiVoiceMode.values.firstWhere(
        (t) => t.name == name,
        orElse: () => KioskAiVoiceMode.auto,
      );
}

class Kiosk extends Equatable {
  final String id;
  final String name;
  final String deviceId;
  final bool active;

  /// Tema kios — default mengikuti tema login (gradient indigo gelap).
  final KioskBgType bgType;

  /// Warna latar saat [bgType] == [KioskBgType.color]. Hex string mis.
  /// `#0D0A2E`. Null saat tipe lain.
  final String? bgColor;

  /// URL gambar latar saat [bgType] == [KioskBgType.image]. Null saat
  /// tipe lain.
  final String? bgImageUrl;

  /// Warna aksen tombol/kartu layanan. Hex string. Null = default
  /// indigo (`#6366F1`).
  final String? buttonColor;

  /// URL logo yang dicetak di tiket. Null = tanpa logo. Untuk printer
  /// thermal idealnya PNG monokrom kontras tinggi.
  final String? printLogoUrl;

  /// Nama perusahaan yang dicetak di kepala tiket.
  final String? printCompanyName;

  /// Sub-judul di bawah nama perusahaan (mis. tagline / nama cabang).
  final String? printCompanySubtitle;

  /// Teks header tambahan, multi-baris (mis. alamat + telepon).
  final String? printHeaderText;

  /// Teks footer, multi-baris (mis. info kontak / pesan terima kasih).
  final String? printFooterText;

  /// Override per-kios untuk Voice AI. Default `auto` (ikut global).
  final KioskAiVoiceMode aiVoiceMode;

  final DateTime? createdAt;

  const Kiosk({
    required this.id,
    required this.name,
    required this.deviceId,
    this.active = true,
    this.bgType = KioskBgType.gradient,
    this.bgColor,
    this.bgImageUrl,
    this.buttonColor,
    this.printLogoUrl,
    this.printCompanyName,
    this.printCompanySubtitle,
    this.printHeaderText,
    this.printFooterText,
    this.aiVoiceMode = KioskAiVoiceMode.auto,
    this.createdAt,
  });

  /// Apakah voice mode aktif untuk kios ini, mempertimbangkan override
  /// lokal + master switch global.
  bool isVoiceEnabled({required bool globalEnabled}) {
    switch (aiVoiceMode) {
      case KioskAiVoiceMode.forceOn:
        return true;
      case KioskAiVoiceMode.forceOff:
        return false;
      case KioskAiVoiceMode.auto:
        return globalEnabled;
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'deviceId': deviceId,
        'active': active,
        'bgType': bgType.name,
        'bgColor': bgColor,
        'bgImageUrl': bgImageUrl,
        'buttonColor': buttonColor,
        'printLogoUrl': printLogoUrl,
        'printCompanyName': printCompanyName,
        'printCompanySubtitle': printCompanySubtitle,
        'printHeaderText': printHeaderText,
        'printFooterText': printFooterText,
        'aiVoiceMode': aiVoiceMode.name,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      };

  factory Kiosk.fromMap(Map<String, dynamic> map) {
    final raw = map['createdAt'];
    DateTime? created;
    if (raw is Timestamp) created = raw.toDate();
    if (raw is DateTime) created = raw;
    String? str(String key) {
      final v = map[key];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return Kiosk(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      deviceId: map['deviceId']?.toString() ?? '',
      active: (map['active'] as bool?) ?? true,
      bgType: KioskBgType.fromName(map['bgType']?.toString()),
      bgColor: str('bgColor'),
      bgImageUrl: str('bgImageUrl'),
      buttonColor: str('buttonColor'),
      printLogoUrl: str('printLogoUrl'),
      printCompanyName: str('printCompanyName'),
      printCompanySubtitle: str('printCompanySubtitle'),
      printHeaderText: str('printHeaderText'),
      printFooterText: str('printFooterText'),
      aiVoiceMode: KioskAiVoiceMode.fromName(map['aiVoiceMode']?.toString()),
      createdAt: created,
    );
  }

  @override
  List<Object?> get props => [id];
}
