// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loket_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoketController)
final loketControllerProvider = LoketControllerProvider._();

final class LoketControllerProvider
    extends $NotifierProvider<LoketController, int> {
  LoketControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loketControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loketControllerHash();

  @$internal
  @override
  LoketController create() => LoketController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$loketControllerHash() => r'7464f6fd9248ca1ed460b398cc4b15b0d028aa56';

abstract class _$LoketController extends $Notifier<int> {
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
