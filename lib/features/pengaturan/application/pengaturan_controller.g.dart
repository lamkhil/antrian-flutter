// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengaturan_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PengaturanController)
final pengaturanControllerProvider = PengaturanControllerProvider._();

final class PengaturanControllerProvider
    extends $NotifierProvider<PengaturanController, int> {
  PengaturanControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pengaturanControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pengaturanControllerHash();

  @$internal
  @override
  PengaturanController create() => PengaturanController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$pengaturanControllerHash() =>
    r'7146b61120d210c05489ff759cbad1576e0836cf';

abstract class _$PengaturanController extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
