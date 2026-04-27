/// Stub untuk non-web. Implementasi sebenarnya ada di
/// `kiosk_printer_browser_web.dart` dan dipilih lewat conditional import
/// (`if (dart.library.html)`).
class KioskPrinterBrowser {
  static Future<bool> printHtml(String html) async => false;
}
