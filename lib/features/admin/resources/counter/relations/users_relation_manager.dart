import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/admin_user_service.dart';
import '../../../../../data/firestore_data_source.dart';
import '../../../../../models/app_user.dart';
import '../../../../../models/counter.dart';
import '../../user/user_resource.dart';

/// Users currently assigned to this counter (via `users.counterId`).
class CounterUsersRelationManager
    extends RelationManager<Counter, AppUser> {
  final Map<String, FirestoreDataSource<AppUser>> _cache = {};
  final _adminUserService = AdminUserService();

  FirestoreDataSource<AppUser> _resolve(Counter parent) =>
      _cache.putIfAbsent(
        parent.id,
        () => FirestoreDataSource<AppUser>(
          collection: FirebaseFirestore.instance.collection('users'),
          fromMap: AppUser.fromMap,
          toMap: (u) => u.toMap(),
          idOf: (u) => u.id,
          whereEquals: {'counterId': parent.id},
          deleteHook: userDataSource.deleteHook,
          createOverride: (data) async {
            final email = (data['email'] as String?)?.trim() ?? '';
            final password = (data['password'] as String?) ?? '';
            final name = (data['name'] as String?)?.trim() ?? '';
            if (email.isEmpty || password.isEmpty) {
              throw StateError('Email dan password wajib diisi');
            }
            return _adminUserService.createUser(
              email: email,
              password: password,
              name: name,
              role: UserRole.counter,
              counterId: parent.id,
            );
          },
        ),
      );

  @override
  String get title => 'Pengguna';

  @override
  IconData? get icon => Icons.people_outline;

  @override
  String get description =>
      'Daftar pengguna yang ditugaskan ke loket ini.';

  @override
  String childId(AppUser record) => record.id;

  @override
  DataSource<AppUser> dataSource(Counter parent) => _resolve(parent);

  @override
  TableSchema<AppUser> table(Counter parent) {
    final ds = _resolve(parent);
    return TableSchema<AppUser>(
      defaultSort: 'name',
      searchable: false,
      paginated: false,
      emptyTitle: 'Belum ada pengguna',
      emptyDescription:
          'Tambahkan pengguna baru lewat tombol di atas, atau pengguna existing bisa pilih loket ini saat login.',
      headerActions: [
        HeaderAction(
          name: 'attach',
          label: 'Pilih Pengguna',
          icon: Icons.person_search_outlined,
          color: ActionColor.gray,
          onPressed: (ctx) async {
            await showDialog<void>(
              context: ctx,
              builder: (_) => _AttachUserDialog(parent: parent, ds: ds),
            );
          },
        ),
        HeaderAction(
          name: 'create',
          label: 'Tambah Pengguna',
          icon: Icons.person_add_alt_1,
          onPressed: (ctx) async {
            await showDialog<void>(
              context: ctx,
              builder: (_) => _CreateUserDialog(parent: parent, ds: ds),
            );
          },
        ),
      ],
      columns: [
        TextColumn<AppUser>(
          name: 'name',
          label: 'Nama',
          accessor: (u) => u.name,
          bold: true,
        ),
        TextColumn<AppUser>(
          name: 'email',
          label: 'Email',
          accessor: (u) => u.email,
        ),
        BadgeColumn<AppUser>(
          name: 'role',
          label: 'Peran',
          accessor: (u) => u.role.label,
          color: (u) =>
              u.role == UserRole.admin ? Colors.indigo : Colors.teal,
        ),
        BooleanColumn<AppUser>(
          name: 'paused',
          label: 'Istirahat',
          accessor: (u) => u.paused,
        ),
      ],
      rowActions: [
        RowAction.edit<AppUser>((ctx, row) async {
          final panel = PanelProvider.of(ctx);
          ctx.go(panel.resourcePath('users', subPath: '${row.id}/edit'));
        }),
        RowAction<AppUser>(
          name: 'detach',
          label: 'Lepas dari loket',
          icon: Icons.link_off,
          color: ActionColor.warning,
          requiresConfirmation: true,
          confirmationTitle: 'Lepas pengguna dari loket?',
          confirmationMessage:
              'Akun pengguna tetap ada, hanya tidak terikat ke loket ini lagi.',
          onPressed: (ctx, row) async {
            await ds.update(row.id, {'counterId': null});
          },
        ),
        RowAction.delete<AppUser>((ctx, row) async {
          await ds.delete(row.id);
        }),
      ],
    );
  }
}

class _AttachUserDialog extends StatefulWidget {
  final Counter parent;
  final FirestoreDataSource<AppUser> ds;

  const _AttachUserDialog({required this.parent, required this.ds});

  @override
  State<_AttachUserDialog> createState() => _AttachUserDialogState();
}

class _AttachUserDialogState extends State<_AttachUserDialog> {
  bool _loading = true;
  Object? _error;
  List<AppUser> _candidates = const [];
  String _query = '';
  String? _attachingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: UserRole.counter.name)
          .get();
      if (!mounted) return;
      final all = snap.docs
          .map((d) => AppUser.fromMap({...d.data(), 'id': d.id}))
          .toList();
      setState(() {
        _candidates = all
            .where((u) => u.counterId != widget.parent.id)
            .toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _attach(AppUser user) async {
    setState(() => _attachingId = user.id);
    try {
      await widget.ds.update(user.id, {'counterId': widget.parent.id});
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${user.name.isEmpty ? user.email : user.name} dipasang ke ${widget.parent.name}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _attachingId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }

  List<AppUser> get _filtered {
    if (_query.isEmpty) return _candidates;
    final q = _query.toLowerCase();
    return _candidates
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pilih Pengguna untuk ${widget.parent.name}'),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      content: SizedBox(
        width: 420,
        height: 440,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Cari nama atau email…',
                prefixIcon: Icon(Icons.search, size: 18),
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildList()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text('$_error',
            style: const TextStyle(color: Colors.redAccent)),
      );
    }
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _candidates.isEmpty
                ? 'Tidak ada pengguna role Loket lain. Pakai tombol "Tambah Pengguna" untuk membuat baru.'
                : 'Tidak ada hasil untuk "$_query".',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final u = list[i];
        final attaching = _attachingId == u.id;
        final hasOtherCounter =
            u.counterId != null && u.counterId!.isNotEmpty;
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text(u.name.isEmpty ? '(tanpa nama)' : u.name,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
            hasOtherCounter
                ? '${u.email} • dipindah dari loket lain'
                : '${u.email} • belum punya loket',
            style: TextStyle(
              color: hasOtherCounter ? Colors.orange.shade800 : Colors.black54,
              fontSize: 12,
            ),
          ),
          trailing: attaching
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_link, size: 18),
          enabled: _attachingId == null,
          onTap: () => _attach(u),
        );
      },
    );
  }
}

class _CreateUserDialog extends StatefulWidget {
  final Counter parent;
  final FirestoreDataSource<AppUser> ds;

  const _CreateUserDialog({required this.parent, required this.ds});

  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _saving = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.ds.create({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passwordCtrl.text,
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Pengguna "${_nameCtrl.text.trim()}" dibuat')),
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
      title: Text('Tambah Pengguna ke ${widget.parent.name}'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama wajib diisi'
                    : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return 'Email wajib diisi';
                  if (!s.contains('@')) return 'Email tidak valid';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePass,
                decoration: InputDecoration(
                  labelText: 'Password',
                  helperText: 'Minimal 6 karakter.',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password wajib diisi';
                  if (v.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              Text(
                'Peran: Loket — terikat otomatis ke ${widget.parent.name}.',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
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
