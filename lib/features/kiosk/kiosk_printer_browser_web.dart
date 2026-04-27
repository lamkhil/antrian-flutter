// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Cetak via dialog browser (`window.print()`). Render [content] ke iframe
/// tersembunyi via `srcdoc` lalu trigger print di iframe-nya. Browser akan
/// menampilkan dialog OS — user klik "Print" (kecuali Chrome/Edge dijalankan
/// dengan flag `--kiosk --kiosk-printing` untuk auto-cetak ke default).
class KioskPrinterBrowser {
  static Future<bool> printHtml(String content) async {
    try {
      final iframe = html.IFrameElement()
        ..srcdoc = content
        ..style.position = 'fixed'
        ..style.right = '0'
        ..style.bottom = '0'
        ..style.width = '0'
        ..style.height = '0'
        ..style.border = '0';

      final completer = Completer<bool>();
      iframe.onLoad.first.then((_) async {
        // Beri sedikit delay untuk pastikan style ter-apply sebelum print.
        await Future<void>.delayed(const Duration(milliseconds: 80));
        try {
          final win = iframe.contentWindow as html.Window;
          win.print();
          if (!completer.isCompleted) completer.complete(true);
        } catch (_) {
          if (!completer.isCompleted) completer.complete(false);
        }
      });

      html.document.body!.append(iframe);

      // Timeout kalau onLoad nggak pernah fire.
      Timer(const Duration(seconds: 10), () {
        if (!completer.isCompleted) completer.complete(false);
      });

      final ok = await completer.future;
      // Hapus iframe setelah print kemungkinan selesai. Kalau dihapus
      // terlalu cepat, beberapa browser membatalkan render.
      Timer(const Duration(seconds: 5), iframe.remove);
      return ok;
    } catch (_) {
      return false;
    }
  }
}
