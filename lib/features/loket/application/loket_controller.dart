import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loket_controller.g.dart';

@riverpod
class LoketController extends _$LoketController {
  @override
  int build() => 0;

  void increment() => state++;
}