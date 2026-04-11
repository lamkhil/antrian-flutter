// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layanan_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LayananController)
final layananControllerProvider = LayananControllerProvider._();

final class LayananControllerProvider
    extends $NotifierProvider<LayananController, LayananState> {
  LayananControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'layananControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$layananControllerHash();

  @$internal
  @override
  LayananController create() => LayananController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LayananState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LayananState>(value),
    );
  }
}

String _$layananControllerHash() => r'6c1d4ca589cc75d72b79fad825d2624e61538630';

abstract class _$LayananController extends $Notifier<LayananState> {
  LayananState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LayananState, LayananState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LayananState, LayananState>,
              LayananState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
