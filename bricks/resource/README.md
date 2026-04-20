# resource brick

Generate a full Filament-style resource: service + form schema + table
schema + `Resource<T>` subclass. Auto-registers into `adminPanel` in
`lib/core/filament/panel_config.dart`.

```bash
mason make resource \
  --name Produk \
  --label "Produk" \
  --pluralLabel "Produk" \
  --icon inventory_2 \
  --group "Master Data" \
  --fields "nama:String, harga:int, aktif:bool"
```

Prerequisites:
- `mason make model --name Produk --fields "..."` should be run first
  (or the model must already exist).
- `lib/core/filament/panel_config.dart` must contain the
  `// filament:resources-begin` / `// filament:imports` markers.

After generating, the resource is available at `/admin/produk` (list),
`/admin/produk/create`, `/admin/produk/:id` (view), `/admin/produk/:id/edit`.

Edit `lib/features/<slug>/<slug>_resource.dart` to refine form fields,
table columns, row actions, etc. The generated resource uses
`MemoryDataSource` by default — swap in your real data source via
`<Name>Services.dataSource = FirestoreDataSource(...)`.
