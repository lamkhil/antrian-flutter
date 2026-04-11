import 'package:riverpod_annotation/riverpod_annotation.dart';

part '{{name}}_controller.g.dart';

@riverpod
class {{name.pascalCase()}}Controller extends _${{name.pascalCase()}}Controller {
  @override
  int build() => 0;

  void increment() => state++;
}