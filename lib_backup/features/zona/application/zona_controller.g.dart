// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zona_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ZonaController)
final zonaControllerProvider = ZonaControllerProvider._();

final class ZonaControllerProvider
    extends $NotifierProvider<ZonaController, ZonaState> {
  ZonaControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'zonaControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$zonaControllerHash();

  @$internal
  @override
  ZonaController create() => ZonaController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ZonaState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ZonaState>(value),
    );
  }
}

String _$zonaControllerHash() => r'b0c114e6dc90680df222626a1c060ee448c2a9cc';

abstract class _$ZonaController extends $Notifier<ZonaState> {
  ZonaState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ZonaState, ZonaState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ZonaState, ZonaState>,
              ZonaState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
