# model brick

Generate a Dart model in `lib/data/models/`.

```bash
mason make model --name Produk --fields "nama:String, harga:int, aktif:bool, createdAt:DateTime"
```

Supported types: `String`, `int`, `double`, `num`, `bool`, `DateTime`
(all optional when `?`-suffixed).

Output: `lib/data/models/produk.dart` with `fromJson`, `toJson`,
`copyWith`, and `Equatable.props` based on `id`.
