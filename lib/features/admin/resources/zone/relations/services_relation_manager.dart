import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/firestore_data_source.dart';
import '../../../../../models/service.dart';
import '../../../../../models/zone.dart';
import '../../service/service_resource.dart';

/// Services that belong to this zone (via `services.zoneId`).
class ZoneServicesRelationManager extends RelationManager<Zone, Service> {
  final Map<String, FirestoreDataSource<Service>> _cache = {};

  FirestoreDataSource<Service> _resolve(Zone parent) => _cache.putIfAbsent(
        parent.id,
        () => FirestoreDataSource<Service>(
          collection: FirebaseFirestore.instance.collection('services'),
          fromMap: Service.fromMap,
          toMap: (s) => s.toMap(),
          idOf: (s) => s.id,
          whereEquals: {'zoneId': parent.id},
          deleteHook: serviceDataSource.deleteHook,
        ),
      );

  @override
  String get title => 'Layanan';

  @override
  IconData? get icon => Icons.support_agent_outlined;

  @override
  String get description => 'Daftar layanan yang berada di zona ini.';

  @override
  String childId(Service record) => record.id;

  @override
  DataSource<Service> dataSource(Zone parent) => _resolve(parent);

  @override
  TableSchema<Service> table(Zone parent) {
    final ds = _resolve(parent);
    return TableSchema<Service>(
      defaultSort: 'name',
      searchable: false,
      paginated: false,
      emptyTitle: 'Belum ada layanan',
      emptyDescription:
          'Tambahkan layanan baru lewat tombol di atas atau menu Layanan.',
      headerActions: [
        HeaderAction(
          name: 'create',
          label: 'Tambah Layanan',
          icon: Icons.add,
          onPressed: (ctx) async {
            await showDialog<void>(
              context: ctx,
              builder: (_) => _CreateServiceDialog(parent: parent, ds: ds),
            );
          },
        ),
      ],
      columns: [
        TextColumn<Service>(
          name: 'name',
          label: 'Nama',
          accessor: (s) => s.name,
          bold: true,
        ),
        TextColumn<Service>(
          name: 'code',
          label: 'Kode',
          accessor: (s) => s.code ?? '-',
        ),
      ],
      rowActions: [
        RowAction.edit<Service>((ctx, row) async {
          final panel = PanelProvider.of(ctx);
          ctx.go(panel.resourcePath('services', subPath: '${row.id}/edit'));
        }),
        RowAction.delete<Service>((ctx, row) async {
          await ds.delete(row.id);
        }),
      ],
    );
  }
}

class _CreateServiceDialog extends StatefulWidget {
  final Zone parent;
  final FirestoreDataSource<Service> ds;

  const _CreateServiceDialog({required this.parent, required this.ds});

  @override
  State<_CreateServiceDialog> createState() => _CreateServiceDialogState();
}

class _CreateServiceDialogState extends State<_CreateServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final code = _codeCtrl.text.trim();
      await widget.ds.create({
        'name': _nameCtrl.text.trim(),
        'code': code.isEmpty ? null : code,
        'zoneId': widget.parent.id,
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Layanan "${_nameCtrl.text.trim()}" dibuat')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tambah Layanan ke ${widget.parent.name}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nama Layanan',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Kode (opsional)',
                helperText: 'Dipakai sebagai prefix nomor antrian, mis. "A".',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _submit,
          icon: _saving
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save, size: 16),
          label: const Text('Simpan'),
        ),
      ],
    );
  }
}
