import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/firestore_data_source.dart';
import '../../../../../models/counter.dart';
import '../../../../../models/service.dart';
import '../../counter/counter_resource.dart';

/// Counters yang melayani layanan ini (via `counters.serviceIds` array).
///
/// Many-to-many: dilist via `arrayContains: serviceId`. Detach = update
/// `serviceIds` di counter doc tanpa menghapus counter; Delete = hapus
/// counter sepenuhnya.
class ServiceCountersRelationManager
    extends RelationManager<Service, Counter> {
  final Map<String, FirestoreDataSource<Counter>> _cache = {};

  FirestoreDataSource<Counter> _resolve(Service parent) => _cache.putIfAbsent(
        parent.id,
        () => FirestoreDataSource<Counter>(
          collection: FirebaseFirestore.instance.collection('counters'),
          fromMap: Counter.fromMap,
          toMap: (c) => c.toMap(),
          idOf: (c) => c.id,
          whereArrayContains: {'serviceIds': parent.id},
          deleteHook: counterDataSource.deleteHook,
        ),
      );

  @override
  String get title => 'Loket';

  @override
  IconData? get icon => Icons.point_of_sale_outlined;

  @override
  String get description =>
      'Daftar loket yang melayani layanan ini.';

  @override
  String childId(Counter record) => record.id;

  @override
  DataSource<Counter> dataSource(Service parent) => _resolve(parent);

  @override
  TableSchema<Counter> table(Service parent) {
    final ds = _resolve(parent);
    return TableSchema<Counter>(
      defaultSort: 'name',
      searchable: false,
      paginated: false,
      emptyTitle: 'Belum ada loket',
      emptyDescription:
          'Tambahkan loket baru lewat tombol di atas, atau buka menu Loket dan centang layanan ini pada salah satu loket.',
      headerActions: [
        HeaderAction(
          name: 'create',
          label: 'Tambah Loket',
          icon: Icons.add,
          onPressed: (ctx) async {
            await showDialog<void>(
              context: ctx,
              builder: (_) => _CreateCounterDialog(parent: parent, ds: ds),
            );
          },
        ),
      ],
      columns: [
        TextColumn<Counter>(
          name: 'name',
          label: 'Nama Loket',
          accessor: (c) => c.name,
          bold: true,
        ),
        TextColumn<Counter>(
          name: 'serviceIds',
          label: 'Total Layanan',
          accessor: (c) => '${c.serviceIds.length} layanan',
        ),
      ],
      rowActions: [
        RowAction.edit<Counter>((ctx, row) async {
          final panel = PanelProvider.of(ctx);
          ctx.go(panel.resourcePath('counters', subPath: '${row.id}/edit'));
        }),
        RowAction<Counter>(
          name: 'detach',
          label: 'Lepas dari layanan',
          icon: Icons.link_off,
          color: ActionColor.warning,
          requiresConfirmation: true,
          confirmationTitle: 'Lepas loket dari layanan ini?',
          confirmationMessage:
              'Loket tetap ada, hanya tidak lagi melayani layanan ini.',
          onPressed: (ctx, row) async {
            final remaining =
                row.serviceIds.where((id) => id != parent.id).toList();
            await ds.update(row.id, {'serviceIds': remaining});
          },
        ),
        RowAction.delete<Counter>((ctx, row) async {
          await ds.delete(row.id);
        }),
      ],
    );
  }
}

class _CreateCounterDialog extends StatefulWidget {
  final Service parent;
  final FirestoreDataSource<Counter> ds;

  const _CreateCounterDialog({required this.parent, required this.ds});

  @override
  State<_CreateCounterDialog> createState() => _CreateCounterDialogState();
}

class _CreateCounterDialogState extends State<_CreateCounterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.ds.create({
        'name': _nameCtrl.text.trim(),
        'serviceIds': [widget.parent.id],
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loket "${_nameCtrl.text.trim()}" dibuat')),
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
      title: Text('Tambah Loket untuk ${widget.parent.name}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nama Loket',
                helperText:
                    'Loket akan otomatis melayani layanan ini. Layanan lain bisa ditambah lewat halaman Loket.',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
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

