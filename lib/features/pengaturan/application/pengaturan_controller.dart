import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pengaturan_controller.g.dart';

@riverpod
class PengaturanController extends _$PengaturanController {
  @override
  int build() => 0;

  void increment() => state++;
}