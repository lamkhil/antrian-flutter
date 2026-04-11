import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'laporan_controller.g.dart';

@riverpod
class LaporanController extends _$LaporanController {
  @override
  int build() => 0;

  void increment() => state++;
}