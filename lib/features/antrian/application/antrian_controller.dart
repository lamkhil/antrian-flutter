import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'antrian_controller.g.dart';

@riverpod
class AntrianController extends _$AntrianController {
  @override
  int build() => 0;

  void increment() => state++;
}