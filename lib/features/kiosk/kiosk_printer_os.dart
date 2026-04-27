/// Stub untuk web (tidak ada `dart:ffi`/`dart:io`). Implementasi sebenarnya
/// ada di `kiosk_printer_os_io.dart` dan dipilih lewat conditional import
/// (`if (dart.library.io)`).
class KioskPrinterOs {
  static Future<List<String>> listPrinters() async => const [];

  static Future<bool> printRaw({
    required String printerName,
    required List<int> bytes,
  }) async =>
      false;
}
