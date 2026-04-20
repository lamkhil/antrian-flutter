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
    extends $NotifierProvider<LoketController, LoketState> {
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
  Override overrideWithValue(LoketState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoketState>(value),
    );
  }
}

String _$loketControllerHash() => r'b8aac980cde2c518ef69615b5d98b26252ead5ad';

abstract class _$LoketController extends $Notifier<LoketState> {
  LoketState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LoketState, LoketState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoketState, LoketState>,
              LoketState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
