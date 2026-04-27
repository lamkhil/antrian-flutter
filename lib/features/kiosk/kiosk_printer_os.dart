import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

/// Cetak ESC/POS lewat antrian printer sistem operasi.
///
/// - Linux/macOS: spawn `lp -d <name> -o raw` lalu pipe bytes ke stdin.
///   Printer harus sudah terpasang di CUPS (Settings > Printers).
/// - Windows: FFI ke `winspool.drv` (`OpenPrinter`/`StartDocPrinter` +
///   datatype `RAW`). Printer harus sudah terpasang di Settings > Printers.
///
/// Dipanggil hanya kalau `Platform.isLinux/macOS/Windows`. Selain itu return
/// list kosong / `false`.
class KioskPrinterOs {
  static Future<List<String>> listPrinters() async {
    if (Platform.isWindows) return _listWindowsPrinters();
    if (Platform.isLinux || Platform.isMacOS) return _listLpstatPrinters();
    return const [];
  }

  static Future<bool> printRaw({
    required String printerName,
    required List<int> bytes,
  }) async {
    if (printerName.isEmpty || bytes.isEmpty) return false;
    if (Platform.isWindows) return _printWindowsRaw(printerName, bytes);
    if (Platform.isLinux || Platform.isMacOS) return _printLpRaw(printerName, bytes);
    return false;
  }

  // ── CUPS (Linux/macOS) ────────────────────────────────────────────
  static Future<List<String>> _listLpstatPrinters() async {
    try {
      final r = await Process.run('lpstat', ['-a']);
      if (r.exitCode != 0) return const [];
      final out = (r.stdout as String).trim();
      if (out.isEmpty) return const [];
      // Format: "<name> accepting requests since ..."
      return out
          .split('\n')
          .map((line) {
            final i = line.indexOf(' ');
            return i < 0 ? line.trim() : line.substring(0, i).trim();
          })
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
    } catch (_) {
      return const [];
    }
  }

  static Future<bool> _printLpRaw(String name, List<int> bytes) async {
    try {
      final p = await Process.start('lp', ['-d', name, '-o', 'raw']);
      p.stdin.add(bytes);
      await p.stdin.flush();
      await p.stdin.close();
      final exit = await p.exitCode;
      return exit == 0;
    } catch (_) {
      return false;
    }
  }

  // ── Windows (winspool.drv via FFI) ────────────────────────────────
  static Future<List<String>> _listWindowsPrinters() async {
    try {
      final lib = DynamicLibrary.open('winspool.drv');
      final enumPrinters = lib.lookupFunction<_EnumPrintersWNative,
          _EnumPrintersWDart>('EnumPrintersW');

      // PRINTER_ENUM_LOCAL (2) | PRINTER_ENUM_CONNECTIONS (4) = 6
      const flags = 6;
      const level = 4;

      final pcbNeeded = calloc<Uint32>();
      final pcReturned = calloc<Uint32>();
      try {
        // First call: empty buffer to get required size.
        enumPrinters(flags, nullptr, level, nullptr, 0, pcbNeeded, pcReturned);
        final cbNeeded = pcbNeeded.value;
        if (cbNeeded == 0) return const [];

        final buffer = calloc<Uint8>(cbNeeded);
        try {
          final ok = enumPrinters(flags, nullptr, level, buffer, cbNeeded,
              pcbNeeded, pcReturned);
          if (ok == 0) return const [];
          final count = pcReturned.value;
          if (count == 0) return const [];

          final size = sizeOf<_PrinterInfo4W>();
          final out = <String>[];
          for (var i = 0; i < count; i++) {
            final ptr = Pointer<_PrinterInfo4W>.fromAddress(
                buffer.address + i * size);
            final namePtr = ptr.ref.pPrinterName;
            if (namePtr != nullptr) {
              out.add(namePtr.toDartString());
            }
          }
          out.sort();
          return out;
        } finally {
          calloc.free(buffer);
        }
      } finally {
        calloc.free(pcbNeeded);
        calloc.free(pcReturned);
      }
    } catch (_) {
      return const [];
    }
  }

  static Future<bool> _printWindowsRaw(String name, List<int> bytes) async {
    try {
      final lib = DynamicLibrary.open('winspool.drv');
      final openPrinter =
          lib.lookupFunction<_OpenPrinterWNative, _OpenPrinterWDart>(
              'OpenPrinterW');
      final closePrinter =
          lib.lookupFunction<_ClosePrinterNative, _ClosePrinterDart>(
              'ClosePrinter');
      final startDoc = lib.lookupFunction<_StartDocPrinterWNative,
          _StartDocPrinterWDart>('StartDocPrinterW');
      final endDoc =
          lib.lookupFunction<_EndDocPrinterNative, _EndDocPrinterDart>(
              'EndDocPrinter');
      final startPage =
          lib.lookupFunction<_StartPagePrinterNative, _StartPagePrinterDart>(
              'StartPagePrinter');
      final endPage =
          lib.lookupFunction<_EndPagePrinterNative, _EndPagePrinterDart>(
              'EndPagePrinter');
      final writePrinter =
          lib.lookupFunction<_WritePrinterNative, _WritePrinterDart>(
              'WritePrinter');

      final namePtr = name.toNativeUtf16();
      final docNamePtr = 'Antrian Ticket'.toNativeUtf16();
      final dataTypePtr = 'RAW'.toNativeUtf16();
      final phPrinter = calloc<IntPtr>();
      final docInfo = calloc<_DocInfo1W>();
      final pcWritten = calloc<Uint32>();
      Pointer<Uint8>? bytesPtr;

      try {
        if (openPrinter(namePtr, phPrinter, nullptr) == 0) return false;
        final hPrinter = phPrinter.value;
        if (hPrinter == 0) return false;

        var ok = false;
        try {
          docInfo.ref.pDocName = docNamePtr;
          docInfo.ref.pOutputFile = nullptr;
          docInfo.ref.pDatatype = dataTypePtr;

          final job = startDoc(hPrinter, 1, docInfo);
          if (job == 0) return false;

          try {
            if (startPage(hPrinter) == 0) return false;
            try {
              bytesPtr = calloc<Uint8>(bytes.length);
              final list = bytesPtr.asTypedList(bytes.length);
              list.setAll(0, bytes);
              final w = writePrinter(
                  hPrinter, bytesPtr, bytes.length, pcWritten);
              ok = w != 0 && pcWritten.value == bytes.length;
            } finally {
              endPage(hPrinter);
            }
          } finally {
            endDoc(hPrinter);
          }
        } finally {
          closePrinter(hPrinter);
        }
        return ok;
      } finally {
        if (bytesPtr != null) calloc.free(bytesPtr);
        calloc.free(pcWritten);
        calloc.free(docInfo);
        calloc.free(phPrinter);
        calloc.free(dataTypePtr);
        calloc.free(docNamePtr);
        calloc.free(namePtr);
      }
    } catch (_) {
      return false;
    }
  }
}

// ── FFI typedefs (Windows) ──────────────────────────────────────────
typedef _OpenPrinterWNative = Int32 Function(
    Pointer<Utf16> pPrinterName,
    Pointer<IntPtr> phPrinter,
    Pointer<Void> pDefault);
typedef _OpenPrinterWDart = int Function(
    Pointer<Utf16> pPrinterName,
    Pointer<IntPtr> phPrinter,
    Pointer<Void> pDefault);

typedef _ClosePrinterNative = Int32 Function(IntPtr hPrinter);
typedef _ClosePrinterDart = int Function(int hPrinter);

typedef _StartDocPrinterWNative = Int32 Function(
    IntPtr hPrinter, Uint32 level, Pointer<_DocInfo1W> pDocInfo);
typedef _StartDocPrinterWDart = int Function(
    int hPrinter, int level, Pointer<_DocInfo1W> pDocInfo);

typedef _EndDocPrinterNative = Int32 Function(IntPtr hPrinter);
typedef _EndDocPrinterDart = int Function(int hPrinter);

typedef _StartPagePrinterNative = Int32 Function(IntPtr hPrinter);
typedef _StartPagePrinterDart = int Function(int hPrinter);

typedef _EndPagePrinterNative = Int32 Function(IntPtr hPrinter);
typedef _EndPagePrinterDart = int Function(int hPrinter);

typedef _WritePrinterNative = Int32 Function(IntPtr hPrinter,
    Pointer<Uint8> pBuf, Uint32 cbBuf, Pointer<Uint32> pcWritten);
typedef _WritePrinterDart = int Function(
    int hPrinter, Pointer<Uint8> pBuf, int cbBuf, Pointer<Uint32> pcWritten);

typedef _EnumPrintersWNative = Int32 Function(
    Uint32 flags,
    Pointer<Utf16> name,
    Uint32 level,
    Pointer<Uint8> pPrinterEnum,
    Uint32 cbBuf,
    Pointer<Uint32> pcbNeeded,
    Pointer<Uint32> pcReturned);
typedef _EnumPrintersWDart = int Function(
    int flags,
    Pointer<Utf16> name,
    int level,
    Pointer<Uint8> pPrinterEnum,
    int cbBuf,
    Pointer<Uint32> pcbNeeded,
    Pointer<Uint32> pcReturned);

final class _DocInfo1W extends Struct {
  external Pointer<Utf16> pDocName;
  external Pointer<Utf16> pOutputFile;
  external Pointer<Utf16> pDatatype;
}

final class _PrinterInfo4W extends Struct {
  external Pointer<Utf16> pPrinterName;
  external Pointer<Utf16> pServerName;
  @Uint32()
  external int attributes;
}
