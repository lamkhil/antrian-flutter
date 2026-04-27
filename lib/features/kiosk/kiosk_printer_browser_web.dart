// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Cetak via dialog browser. Inject script auto-print ke dalam HTML lalu
/// render via `srcdoc` di iframe tersembunyi. `window.print()` dipanggil
/// **dari dalam iframe** (bukan dari parent) sehingga tidak ada masalah
/// origin di Firefox — iframe `srcdoc` dianggap null origin dari sisi
/// parent, tapi script di dalamnya bebas memanggil `print()` pada window
/// dirinya sendiri. Browser akan menampilkan dialog OS — user klik
/// "Print" (kecuali Chrome/Edge dijalankan dengan flag
/// `--kiosk --kiosk-printing` untuk auto-cetak ke default).
class KioskPrinterBrowser {
  static Future<bool> printHtml(String content) async {
    try {
      final withAutoPrint = _injectAutoPrintScript(content);

      final iframe = html.IFrameElement()
        ..srcdoc = withAutoPrint
        ..style.position = 'fixed'
        ..style.right = '0'
        ..style.bottom = '0'
        ..style.width = '0'
        ..style.height = '0'
        ..style.border = '0';

      html.document.body!.append(iframe);

      // Tidak ada cara reliable mendeteksi kapan dialog ditutup
      // (afterprint event tidak fire di semua browser dari iframe). Anggap
      // berhasil; cleanup iframe setelah delay agar render tidak dibatalkan.
      Timer(const Duration(seconds: 30), iframe.remove);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Tambahkan `<script>` di akhir body yang menunggu `window.onload`
  /// (agar logo selesai decode) lalu memanggil `window.focus()` +
  /// `window.print()`.
  static String _injectAutoPrintScript(String html) {
    const script = '<script>'
        'window.addEventListener("load",function(){'
        'setTimeout(function(){'
        'try{window.focus();window.print();}catch(e){}'
        '},150);'
        '});'
        '</script>';
    final lower = html.toLowerCase();
    final idx = lower.lastIndexOf('</body>');
    if (idx < 0) return '$html$script';
    return '${html.substring(0, idx)}$script${html.substring(idx)}';
  }
}
