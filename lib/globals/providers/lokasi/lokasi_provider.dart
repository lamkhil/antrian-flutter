import 'package:antrian/data/models/lokasi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lokasi_provider.g.dart';

@riverpod
class LokasiProvider extends _$LokasiProvider {
  @override
  Lokasi? build() {
    return null;
  }

  void setLokasi(Lokasi lokasi) => state = lokasi;
}
