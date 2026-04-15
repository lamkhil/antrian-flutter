// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layanan_zona_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LayananZonaController)
final layananZonaControllerProvider = LayananZonaControllerProvider._();

final class LayananZonaControllerProvider
    extends $NotifierProvider<LayananZonaController, LayananZonaState> {
  LayananZonaControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'layananZonaControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$layananZonaControllerHash();

  @$internal
  @override
  LayananZonaController create() => LayananZonaController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LayananZonaState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LayananZonaState>(value),
    );
  }
}

String _$layananZonaControllerHash() =>
    r'0ba7d5f0bd1aeb4189ee36e25e24b77eac3aeeea';

abstract class _$LayananZonaController extends $Notifier<LayananZonaState> {
  LayananZonaState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LayananZonaState, LayananZonaState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LayananZonaState, LayananZonaState>,
              LayananZonaState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
