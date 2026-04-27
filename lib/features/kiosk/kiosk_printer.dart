import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/kiosk.dart';
import '../../models/service.dart';
import '../../models/ticket.dart';
import 'kiosk_printer_browser.dart'
    if (dart.library.html) 'kiosk_printer_browser_web.dart';
import 'kiosk_printer_os.dart';

/// Cara menyalurkan tiket ke printer.
enum KioskPrinterTransport {
  /// Printer thermal Bluetooth (BT Classic SPP). Hanya didukung Android.
  bluetooth,

  /// Printer terpasang di sistem operasi (CUPS/Windows spooler). ESC/POS
  /// bytes dikirim langsung. Didukung di Linux/macOS/Windows.
  osPrinter,

  /// Cetak lewat dialog browser (`window.print()`) — render HTML ke iframe
  /// tersembunyi lalu trigger print. Hanya web. Bukan ESC/POS bytes; format
  /// tiket di-render dengan CSS thermal-style.
  browserPrint;

  String get label => switch (this) {
        KioskPrinterTransport.bluetooth => 'Bluetooth',
        KioskPrinterTransport.osPrinter => 'Printer Sistem',
        KioskPrinterTransport.browserPrint => 'Dialog Browser',
      };

  static KioskPrinterTransport fromName(String? name) =>
      KioskPrinterTransport.values.firstWhere(
        (t) => t.name == name,
        orElse: () => KioskPrinterTransport.osPrinter,
      );
}

/// Printer yang bisa dipilih di dialog (gabungan BT paired + printer OS).
class KioskPrinterDevice {
  /// MAC (BT) atau nama printer OS — ini yang disimpan di config.
  final String address;

  /// Label tampilan untuk user.
  final String label;

  const KioskPrinterDevice({required this.address, required this.label});
}

/// Konfigurasi printer per-perangkat kios.
class KioskPrinterConfig {
  final KioskPrinterTransport transport;
  final String address;
  final String displayName;

  /// 58 atau 80 (mm). Default 58.
  final int paperWidthMm;

  /// Auto-cetak setiap kali tiket berhasil diambil.
  final bool autoPrint;

  const KioskPrinterConfig({
    required this.transport,
    required this.address,
    required this.displayName,
    this.paperWidthMm = 58,
    this.autoPrint = true,
  });

  KioskPrinterConfig copyWith({
    KioskPrinterTransport? transport,
    String? address,
    String? displayName,
    int? paperWidthMm,
    bool? autoPrint,
  }) =>
      KioskPrinterConfig(
        transport: transport ?? this.transport,
        address: address ?? this.address,
        displayName: displayName ?? this.displayName,
        paperWidthMm: paperWidthMm ?? this.paperWidthMm,
        autoPrint: autoPrint ?? this.autoPrint,
      );

  Map<String, dynamic> toJson() => {
        'transport': transport.name,
        'address': address,
        'displayName': displayName,
        'paperWidthMm': paperWidthMm,
        'autoPrint': autoPrint,
      };

  factory KioskPrinterConfig.fromJson(Map<String, dynamic> j) =>
      KioskPrinterConfig(
        transport: KioskPrinterTransport.fromName(j['transport']?.toString()),
        address: (j['address'] ?? j['mac'])?.toString() ?? '',
        displayName: (j['displayName'] ?? j['name'])?.toString() ?? '',
        paperWidthMm: (j['paperWidthMm'] as num?)?.toInt() ?? 58,
        autoPrint: j['autoPrint'] as bool? ?? true,
      );
}

/// Service untuk auto-cetak tiket ESC/POS. Dispatch ke transport sesuai
/// platform: BT di Android, printer OS di desktop.
class KioskPrinter {
  static const _prefKey = 'kiosk_printer_';

  /// Transport default berdasarkan platform aktif. `null` = belum didukung
  /// (mis. iOS) — config tetap bisa dibaca/disimpan tapi cetak no-op.
  static KioskPrinterTransport? get defaultTransport {
    if (kIsWeb) return KioskPrinterTransport.browserPrint;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return KioskPrinterTransport.bluetooth;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return KioskPrinterTransport.osPrinter;
      default:
        return null;
    }
  }

  static bool get isSupported => defaultTransport != null;

  static Future<KioskPrinterConfig?> readConfig(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefKey$deviceId');
    if (raw == null) return null;
    try {
      return KioskPrinterConfig.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      await prefs.remove('$_prefKey$deviceId');
      return null;
    }
  }

  static Future<void> saveConfig(
    String deviceId,
    KioskPrinterConfig cfg,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefKey$deviceId', jsonEncode(cfg.toJson()));
  }

  static Future<void> clearConfig(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefKey$deviceId');
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await PrintBluetoothThermal.disconnect;
      } catch (_) {}
    }
  }

  /// Daftar printer yang bisa dipilih untuk [transport]. Untuk Bluetooth,
  /// hanya printer yang sudah di-pair via Settings Android. Untuk OS,
  /// hanya printer yang sudah dipasang di Settings > Printers OS.
  static Future<List<KioskPrinterDevice>> listDevices(
    KioskPrinterTransport transport,
  ) async {
    switch (transport) {
      case KioskPrinterTransport.bluetooth:
        if (defaultTargetPlatform != TargetPlatform.android) return const [];
        try {
          final paired = await PrintBluetoothThermal.pairedBluetooths;
          return paired
              .map((b) =>
                  KioskPrinterDevice(address: b.macAdress, label: b.name))
              .toList();
        } catch (e) {
          developer.log('list bt failed: $e', name: 'kiosk.printer');
          return const [];
        }
      case KioskPrinterTransport.osPrinter:
        try {
          final names = await KioskPrinterOs.listPrinters();
          return names
              .map((n) => KioskPrinterDevice(address: n, label: n))
              .toList();
        } catch (e) {
          developer.log('list os printers failed: $e', name: 'kiosk.printer');
          return const [];
        }
      case KioskPrinterTransport.browserPrint:
        // Tidak ada konsep "device" — dialog browser pakai daftar printer
        // OS. Kembalikan satu entry virtual supaya UX dialog tetap konsisten.
        return const [
          KioskPrinterDevice(
            address: 'browser',
            label: 'Cetak via Dialog Browser',
          ),
        ];
    }
  }

  /// Cek prasyarat sebelum pakai [transport]. Return pesan error untuk
  /// ditampilkan ke user, atau `null` kalau OK.
  static Future<String?> precheck(KioskPrinterTransport transport) async {
    switch (transport) {
      case KioskPrinterTransport.bluetooth:
        if (defaultTargetPlatform != TargetPlatform.android) {
          return 'Printer Bluetooth hanya didukung di Android.';
        }
        try {
          final on = await PrintBluetoothThermal.bluetoothEnabled;
          if (!on) return 'Bluetooth perangkat sedang mati.';
        } catch (_) {
          return 'Tidak bisa memeriksa status Bluetooth.';
        }
        return null;
      case KioskPrinterTransport.osPrinter:
        if (kIsWeb) return 'Printer sistem tidak didukung di web.';
        return null;
      case KioskPrinterTransport.browserPrint:
        if (!kIsWeb) return 'Cetak via dialog browser hanya tersedia di web.';
        return null;
    }
  }

  static Future<bool> printTicket({
    required Ticket ticket,
    required Service service,
    required Kiosk kiosk,
    required KioskPrinterConfig cfg,
  }) async {
    if (cfg.transport == KioskPrinterTransport.browserPrint) {
      return KioskPrinterBrowser.printHtml(
        _buildTicketHtml(
          ticket: ticket,
          service: service,
          kiosk: kiosk,
          cfg: cfg,
        ),
      );
    }
    final bytes = await _buildTicketBytes(
      ticket: ticket,
      service: service,
      kiosk: kiosk,
      cfg: cfg,
    );
    return _send(cfg, bytes);
  }

  static Future<bool> printTest(KioskPrinterConfig cfg) async {
    if (cfg.transport == KioskPrinterTransport.browserPrint) {
      return KioskPrinterBrowser.printHtml(_buildTestHtml(cfg));
    }
    final paper = cfg.paperWidthMm == 80 ? PaperSize.mm80 : PaperSize.mm58;
    final profile = await CapabilityProfile.load();
    final gen = Generator(paper, profile);
    final bytes = <int>[
      ...gen.text(
        'TEST CETAK',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
      ...gen.feed(1),
      ...gen.text(
        'Printer: ${cfg.displayName}',
        styles: const PosStyles(align: PosAlign.center),
      ),
      ...gen.text(
        '${cfg.paperWidthMm} mm — ${cfg.transport.label}',
        styles: const PosStyles(align: PosAlign.center),
      ),
      ...gen.text(
        DateFormat('dd MMM y HH:mm:ss', 'id_ID').format(DateTime.now()),
        styles: const PosStyles(align: PosAlign.center),
      ),
      ...gen.feed(2),
      ...gen.cut(),
    ];
    return _send(cfg, bytes);
  }

  static Future<bool> _send(KioskPrinterConfig cfg, List<int> bytes) async {
    if (cfg.address.isEmpty) return false;
    switch (cfg.transport) {
      case KioskPrinterTransport.bluetooth:
        return _sendBluetooth(cfg, bytes);
      case KioskPrinterTransport.osPrinter:
        return _sendOsPrinter(cfg, bytes);
      case KioskPrinterTransport.browserPrint:
        // Browser print pakai HTML, bukan bytes — sudah di-handle di
        // [printTicket]/[printTest]. Cabang ini tidak seharusnya dipanggil.
        return false;
    }
  }

  static Future<bool> _sendBluetooth(
    KioskPrinterConfig cfg,
    List<int> bytes,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      var connected = await PrintBluetoothThermal.connectionStatus;
      if (!connected) {
        connected = await PrintBluetoothThermal.connect(
          macPrinterAddress: cfg.address,
        );
      }
      if (!connected) return false;
      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      developer.log('bt print failed: $e', name: 'kiosk.printer');
      return false;
    }
  }

  static Future<bool> _sendOsPrinter(
    KioskPrinterConfig cfg,
    List<int> bytes,
  ) async {
    if (kIsWeb) return false;
    try {
      return await KioskPrinterOs.printRaw(
        printerName: cfg.address,
        bytes: bytes,
      );
    } catch (e) {
      developer.log('os print failed: $e', name: 'kiosk.printer');
      return false;
    }
  }

  static Future<List<int>> _buildTicketBytes({
    required Ticket ticket,
    required Service service,
    required Kiosk kiosk,
    required KioskPrinterConfig cfg,
  }) async {
    final paper = cfg.paperWidthMm == 80 ? PaperSize.mm80 : PaperSize.mm58;
    final printerWidthPx = cfg.paperWidthMm == 80 ? 576 : 384;
    final profile = await CapabilityProfile.load();
    final gen = Generator(paper, profile);
    final ts = DateFormat('dd MMM y HH:mm', 'id_ID').format(DateTime.now());

    final out = <int>[];

    final logoUrl = kiosk.printLogoUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      final logo = await _loadLogo(logoUrl, printerWidthPx);
      if (logo != null) {
        out.addAll(gen.imageRaster(logo, align: PosAlign.center));
      }
    }

    final company = kiosk.printCompanyName;
    if (company != null && company.isNotEmpty) {
      out.addAll(gen.text(
        company,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
        ),
      ));
    }
    final subtitle = kiosk.printCompanySubtitle;
    if (subtitle != null && subtitle.isNotEmpty) {
      out.addAll(gen.text(
        subtitle,
        styles: const PosStyles(align: PosAlign.center),
      ));
    }
    final headerText = kiosk.printHeaderText;
    if (headerText != null && headerText.isNotEmpty) {
      for (final line in headerText.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        out.addAll(gen.text(
          trimmed,
          styles: const PosStyles(align: PosAlign.center),
        ));
      }
    }
    out.addAll(gen.hr());

    out.addAll(gen.text(
      kiosk.name,
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ));
    out.addAll(gen.text(ts,
        styles: const PosStyles(align: PosAlign.center)));
    out.addAll(gen.feed(1));

    out.addAll(gen.text(
      'NOMOR ANTRIAN',
      styles: const PosStyles(align: PosAlign.center),
    ));
    out.addAll(gen.feed(1));
    out.addAll(gen.text(
      ticket.number,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size4,
        width: PosTextSize.size4,
      ),
    ));
    out.addAll(gen.feed(1));
    out.addAll(gen.text('Layanan',
        styles: const PosStyles(align: PosAlign.center)));
    out.addAll(gen.text(
      service.name,
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ));
    out.addAll(gen.hr());

    final footerText = kiosk.printFooterText;
    if (footerText != null && footerText.isNotEmpty) {
      for (final line in footerText.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        out.addAll(gen.text(
          trimmed,
          styles: const PosStyles(align: PosAlign.center),
        ));
      }
    } else {
      out.addAll(gen.text(
        'Mohon menunggu giliran',
        styles: const PosStyles(align: PosAlign.center),
      ));
      out.addAll(gen.text(
        'panggilan di loket.',
        styles: const PosStyles(align: PosAlign.center),
      ));
      out.addAll(gen.feed(1));
      out.addAll(gen.text(
        'Terima kasih',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ));
    }

    out.addAll(gen.feed(2));
    out.addAll(gen.cut());
    return out;
  }

  // ── Logo cache (untuk ESC/POS) ─────────────────────────────────────
  static String? _cachedLogoUrl;
  static int? _cachedLogoWidth;
  static img.Image? _cachedLogo;

  /// Fetch + decode + resize + grayscale logo dari URL. Hasil di-cache
  /// di memori sampai URL atau lebar printer berubah. Dikomputasi sekali
  /// per kios — cetak tiket berikutnya pakai cached image.
  static Future<img.Image?> _loadLogo(String url, int targetWidth) async {
    if (_cachedLogoUrl == url &&
        _cachedLogoWidth == targetWidth &&
        _cachedLogo != null) {
      return _cachedLogo;
    }
    try {
      final resp = await Dio().get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      final bytes = resp.data;
      if (bytes == null || bytes.isEmpty) return null;
      var decoded = img.decodeImage(Uint8List.fromList(bytes));
      if (decoded == null) return null;
      if (decoded.width > targetWidth) {
        decoded = img.copyResize(decoded, width: targetWidth);
      }
      decoded = img.grayscale(decoded);
      _cachedLogoUrl = url;
      _cachedLogoWidth = targetWidth;
      _cachedLogo = decoded;
      return decoded;
    } catch (e) {
      developer.log('logo load failed: $e', name: 'kiosk.printer');
      return null;
    }
  }

  // ── HTML untuk browser print ───────────────────────────────────────
  static String _buildTicketHtml({
    required Ticket ticket,
    required Service service,
    required Kiosk kiosk,
    required KioskPrinterConfig cfg,
  }) {
    final ts = DateFormat('dd MMM y HH:mm', 'id_ID').format(DateTime.now());

    final parts = <String>[];
    final logoUrl = kiosk.printLogoUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      parts.add('<div class="center"><img src="${_esc(logoUrl)}" '
          'class="logo" alt=""/></div>');
    }
    final company = kiosk.printCompanyName;
    if (company != null && company.isNotEmpty) {
      parts.add('<div class="center bold large">${_esc(company)}</div>');
    }
    final subtitle = kiosk.printCompanySubtitle;
    if (subtitle != null && subtitle.isNotEmpty) {
      parts.add('<div class="center small">${_esc(subtitle)}</div>');
    }
    final header = kiosk.printHeaderText;
    if (header != null && header.isNotEmpty) {
      parts.add('<div class="center small">${_escMultiline(header)}</div>');
    }
    parts.add('<hr/>');
    parts.add('<div class="center bold">${_esc(kiosk.name)}</div>');
    parts.add('<div class="center small">$ts</div>');
    parts.add('<hr/>');
    parts.add('<div class="center small">NOMOR ANTRIAN</div>');
    parts.add('<div class="center huge">${_esc(ticket.number)}</div>');
    parts.add('<div class="center small">Layanan</div>');
    parts.add('<div class="center bold">${_esc(service.name)}</div>');
    parts.add('<hr/>');

    final footer = kiosk.printFooterText;
    if (footer != null && footer.isNotEmpty) {
      parts.add('<div class="center small">${_escMultiline(footer)}</div>');
    } else {
      parts.add('<div class="center small">Mohon menunggu giliran<br/>'
          'panggilan di loket.</div>');
      parts.add('<div class="center bold spaced">Terima kasih</div>');
    }

    return _wrapDocument(parts.join('\n'), cfg.paperWidthMm);
  }

  static String _buildTestHtml(KioskPrinterConfig cfg) {
    final ts = DateFormat('dd MMM y HH:mm:ss', 'id_ID').format(DateTime.now());
    final body = '''
<div class="center bold large">TEST CETAK</div>
<div class="center small">Printer: ${_esc(cfg.displayName)}</div>
<div class="center small">${cfg.paperWidthMm} mm — ${_esc(cfg.transport.label)}</div>
<div class="center small">$ts</div>
''';
    return _wrapDocument(body, cfg.paperWidthMm);
  }

  static String _wrapDocument(String body, int paperWidthMm) {
    // CSS thermal-style: monospace, full width, dashed hr. `@page size`
    // memberi tahu printer ukuran kertas; kalau printer tidak support,
    // user bisa override di dialog OS.
    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<style>
  @page { size: ${paperWidthMm}mm auto; margin: 0; }
  html, body { margin: 0; padding: 0; }
  body {
    width: ${paperWidthMm}mm;
    padding: 4mm 3mm;
    font-family: 'Courier New', Consolas, monospace;
    font-size: 10pt;
    color: #000;
    line-height: 1.25;
    box-sizing: border-box;
  }
  .center { text-align: center; }
  .bold { font-weight: 700; }
  .small { font-size: 9pt; }
  .large { font-size: 14pt; }
  .huge { font-size: 36pt; font-weight: 800; line-height: 1; margin: 4mm 0; }
  .spaced { margin-top: 3mm; }
  .logo {
    max-width: 80%;
    max-height: 25mm;
    margin: 0 auto 2mm;
    display: block;
    object-fit: contain;
  }
  hr { border: 0; border-top: 1px dashed #000; margin: 3mm 0; }
  @media print { body { -webkit-print-color-adjust: exact; } }
</style>
</head>
<body>
$body
</body>
</html>
''';
  }

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  /// Escape lalu join newline jadi `<br/>`. Trim per baris, skip yang kosong.
  static String _escMultiline(String s) => s
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .map(_esc)
      .join('<br/>');
}
