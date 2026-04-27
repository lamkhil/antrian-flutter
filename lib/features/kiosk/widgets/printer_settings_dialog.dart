import 'package:flutter/material.dart';

import '../kiosk_printer.dart';

const _kAccentLight = Color(0xFFA5B4FC);
const _kDanger = Color(0xFFF87171);
const _kSuccess = Color(0xFF34D399);

/// Dialog konfigurasi printer per kios. Otomatis memilih transport sesuai
/// platform: Bluetooth di Android, printer OS di Windows/Linux/macOS.
/// Mengembalikan [KioskPrinterConfig] kalau disimpan, atau `null` kalau
/// dibatalkan / dihapus.
class PrinterSettingsDialog extends StatefulWidget {
  final String deviceId;
  final KioskPrinterConfig? initial;

  const PrinterSettingsDialog({
    super.key,
    required this.deviceId,
    this.initial,
  });

  @override
  State<PrinterSettingsDialog> createState() => _PrinterSettingsDialogState();
}

class _PrinterSettingsDialogState extends State<PrinterSettingsDialog> {
  late final KioskPrinterTransport _transport = widget.initial?.transport ??
      KioskPrinter.defaultTransport ??
      KioskPrinterTransport.osPrinter;
  late KioskPrinterConfig? _cfg = widget.initial;
  List<KioskPrinterDevice> _devices = const [];
  bool _loadingDevices = true;
  String? _precheck;
  bool _busy = false;
  String? _status;
  bool _statusOk = false;

  @override
  void initState() {
    super.initState();
    _refreshDevices();
  }

  Future<void> _refreshDevices() async {
    setState(() => _loadingDevices = true);
    final precheck = await KioskPrinter.precheck(_transport);
    final devices = await KioskPrinter.listDevices(_transport);
    if (!mounted) return;
    setState(() {
      _precheck = precheck;
      _devices = devices;
      _loadingDevices = false;
    });
  }

  Future<void> _pickDevice() async {
    final selected = await showModalBottomSheet<KioskPrinterDevice>(
      context: context,
      backgroundColor: const Color(0xFF130E3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _DeviceListSheet(
        transport: _transport,
        devices: _devices,
        loading: _loadingDevices,
        precheck: _precheck,
        onRefresh: _refreshDevices,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _cfg = (_cfg ??
              KioskPrinterConfig(
                transport: _transport,
                address: '',
                displayName: '',
              ))
          .copyWith(
        transport: _transport,
        address: selected.address,
        displayName: selected.label,
      );
      _status = null;
    });
  }

  Future<void> _testPrint() async {
    final cfg = _cfg;
    if (cfg == null || cfg.address.isEmpty) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    final ok = await KioskPrinter.printTest(cfg);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _statusOk = ok;
      _status = ok
          ? 'Berhasil cetak tes.'
          : 'Gagal cetak tes — periksa printer dan koneksi.';
    });
  }

  Future<void> _save() async {
    final cfg = _cfg;
    if (cfg == null || cfg.address.isEmpty) return;
    await KioskPrinter.saveConfig(widget.deviceId, cfg);
    if (!mounted) return;
    Navigator.of(context).pop(cfg);
  }

  Future<void> _clearAndClose() async {
    await KioskPrinter.clearConfig(widget.deviceId);
    if (!mounted) return;
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg;
    final hasDevice = cfg != null && cfg.address.isNotEmpty;

    return Dialog(
      backgroundColor: const Color(0xFF130E3A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.print_outlined, color: _kAccentLight),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Pengaturan Printer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Transport: ${_transport.label}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              if (!KioskPrinter.isSupported) ...[
                const SizedBox(height: 12),
                _Notice(
                  text: 'Cetak otomatis belum didukung di platform ini. '
                      'Tiket tetap tampil di layar.',
                  color: _kAccentLight,
                ),
              ] else if (_precheck != null && !_loadingDevices) ...[
                const SizedBox(height: 12),
                _Notice(text: _precheck!, color: _kDanger),
              ],
              const SizedBox(height: 16),
              _Field(
                label: 'Printer',
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: KioskPrinter.isSupported ? _pickDevice : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasDevice ? cfg.displayName : 'Belum dipilih',
                                style: TextStyle(
                                  color: hasDevice
                                      ? Colors.white
                                      : Colors.white60,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (hasDevice && cfg.address != cfg.displayName)
                                Text(
                                  cfg.address,
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white60),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _Field(
                label: 'Lebar Kertas',
                child: Row(
                  children: [
                    Expanded(
                      child: _PaperChip(
                        label: '58 mm',
                        selected: (cfg?.paperWidthMm ?? 58) == 58,
                        onTap: () => setState(() {
                          _cfg = (cfg ??
                                  KioskPrinterConfig(
                                    transport: _transport,
                                    address: '',
                                    displayName: '',
                                  ))
                              .copyWith(paperWidthMm: 58);
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PaperChip(
                        label: '80 mm',
                        selected: (cfg?.paperWidthMm ?? 58) == 80,
                        onTap: () => setState(() {
                          _cfg = (cfg ??
                                  KioskPrinterConfig(
                                    transport: _transport,
                                    address: '',
                                    displayName: '',
                                  ))
                              .copyWith(paperWidthMm: 80);
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: cfg?.autoPrint ?? true,
                onChanged: (v) => setState(() {
                  _cfg = (cfg ??
                          KioskPrinterConfig(
                            transport: _transport,
                            address: '',
                            displayName: '',
                          ))
                      .copyWith(autoPrint: v);
                }),
                title: const Text(
                  'Cetak otomatis',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Tiket dicetak setiap kali nomor antrian diambil.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                activeThumbColor: _kAccentLight,
              ),
              if (_status != null) ...[
                const SizedBox(height: 8),
                _Notice(
                  text: _status!,
                  color: _statusOk ? _kSuccess : _kDanger,
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy || !hasDevice ? null : _testPrint,
                      icon: _busy
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white70),
                            )
                          : const Icon(Icons.science_outlined,
                              color: Colors.white),
                      label: const Text(
                        'Test Cetak',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: hasDevice ? _save : null,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Simpan'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _kAccentLight,
                        foregroundColor: const Color(0xFF0D0A2E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.initial != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: _kDanger),
                  label: const Text(
                    'Hapus Konfigurasi Printer',
                    style: TextStyle(color: _kDanger),
                  ),
                  onPressed: _clearAndClose,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _PaperChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PaperChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? _kAccentLight.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? _kAccentLight
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  final Color color;
  const _Notice({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12.5),
      ),
    );
  }
}

class _DeviceListSheet extends StatelessWidget {
  final KioskPrinterTransport transport;
  final List<KioskPrinterDevice> devices;
  final bool loading;
  final String? precheck;
  final Future<void> Function() onRefresh;

  const _DeviceListSheet({
    required this.transport,
    required this.devices,
    required this.loading,
    required this.precheck,
    required this.onRefresh,
  });

  String get _title => switch (transport) {
        KioskPrinterTransport.bluetooth => 'Pilih Printer Bluetooth',
        KioskPrinterTransport.osPrinter => 'Pilih Printer Sistem',
        KioskPrinterTransport.browserPrint => 'Cetak via Browser',
      };

  String get _hint => switch (transport) {
        KioskPrinterTransport.bluetooth =>
          'Hanya printer yang sudah dipasangkan di Pengaturan > Bluetooth '
              'Android yang muncul di sini.',
        KioskPrinterTransport.osPrinter =>
          'Hanya printer yang sudah dipasang di Settings > Printers OS '
              'yang muncul di sini. Pasang printer USB lewat OS dulu.',
        KioskPrinterTransport.browserPrint =>
          'Tiket dirender ke iframe lalu memunculkan dialog cetak browser. '
              'User pilih printer di dialog OS — atau jalankan Chrome/Edge '
              'dengan flag --kiosk --kiosk-printing untuk auto-cetak.',
      };

  String get _emptyMsg => switch (transport) {
        KioskPrinterTransport.bluetooth =>
          'Belum ada printer yang dipasangkan. Buka Pengaturan > Bluetooth, '
              'pair printer, lalu tap Refresh.',
        KioskPrinterTransport.osPrinter =>
          'Belum ada printer terpasang di sistem. Pasang printer USB lewat '
              'Settings > Printers OS, lalu tap Refresh.',
        KioskPrinterTransport.browserPrint =>
          'Cetak via dialog browser tidak tersedia.',
      };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh, color: Colors.white60),
                  onPressed: () async => onRefresh(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _hint,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 14),
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (precheck != null)
              _Notice(text: precheck!, color: _kDanger)
            else if (devices.isEmpty)
              _Notice(text: _emptyMsg, color: _kAccentLight)
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: devices.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) {
                    final d = devices[i];
                    final showAddress = d.address != d.label;
                    return Material(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(ctx).pop(d),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.print_outlined,
                                  color: _kAccentLight),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (showAddress)
                                      Text(
                                        d.address,
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: Colors.white38),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
