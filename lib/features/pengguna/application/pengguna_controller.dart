import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pengguna_controller.g.dart';

@riverpod
class PenggunaController extends _$PenggunaController {
  @override
  int build() => 0;

  void increment() => state++;
}