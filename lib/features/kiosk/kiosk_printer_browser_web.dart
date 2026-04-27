// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Cetak via dialog browser (`window.print()`). Render [content] ke iframe
/// tersembunyi pakai `document.open/write/close` (bukan `srcdoc` — Firefox
/// memperlakukan iframe `srcdoc` sebagai null origin sehingga panggilan
/// `contentWindow.print()` gagal silent). Setelah konten ditulis, iframe
/// + contentWindow di-focus eksplisit lalu `print()` dipanggil di
/// contentWindow. Browser akan menampilkan dialog OS — user klik "Print"
/// (kecuali Chrome/Edge dijalankan dengan flag `--kiosk --kiosk-printing`
/// untuk auto-cetak ke default).
class KioskPrinterBrowser {
  static Future<bool> printHtml(String content) async {
    try {
      final iframe = html.IFrameElement()
        ..style.position = 'fixed'
        ..style.right = '0'
        ..style.bottom = '0'
        ..style.width = '0'
        ..style.height = '0'
        ..style.border = '0';

      html.document.body!.append(iframe);

      final win = iframe.contentWindow;
      final doc = win?.document;
      if (win == null || doc == null) {
        iframe.remove();
        return false;
      }

      // Tulis konten via document.open/write/close. Ini memberi iframe
      // origin yang sama dengan parent, jadi contentWindow.print() boleh
      // dipanggil tanpa SecurityError.
      doc.open();
      doc.write(content);
      doc.close();

      // Tunggu image (logo) selesai loading sebelum print, kalau ada.
      // Pakai window.onload daripada DOMContentLoaded agar image juga
      // terhitung.
      final completer = Completer<bool>();
      void firePrint() {
        if (completer.isCompleted) return;
        try {
          // Firefox butuh focus di iframe + contentWindow sebelum print,
          // kalau tidak dialog kadang muncul tapi konten kosong.
          iframe.focus();
          win.focus();
          win.print();
          completer.complete(true);
        } catch (_) {
          completer.complete(false);
        }
      }

      // Jika dokumen sudah complete (no images), langsung print.
      if (doc.readyState == 'complete') {
        // Beri 1 frame supaya layout settle dulu.
        Timer(const Duration(milliseconds: 50), firePrint);
      } else {
        win.onLoad.first.then((_) {
          Timer(const Duration(milliseconds: 50), firePrint);
        });
        // Fallback timeout — tetap coba print setelah 3 detik kalau onLoad
        // tidak pernah fire (misal logo gagal load).
        Timer(const Duration(seconds: 3), firePrint);
      }

      // Hard timeout: kalau print() pun gagal.
      Timer(const Duration(seconds: 10), () {
        if (!completer.isCompleted) completer.complete(false);
      });

      final ok = await completer.future;
      // Hapus iframe setelah dialog kemungkinan ditutup. Hapus terlalu
      // cepat membatalkan render di sebagian browser.
      Timer(const Duration(seconds: 5), iframe.remove);
      return ok;
    } catch (_) {
      return false;
    }
  }
}
