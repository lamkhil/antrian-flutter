// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengguna_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PenggunaController)
final penggunaControllerProvider = PenggunaControllerProvider._();

final class PenggunaControllerProvider
    extends $NotifierProvider<PenggunaController, PenggunaState> {
  PenggunaControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'penggunaControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$penggunaControllerHash();

  @$internal
  @override
  PenggunaController create() => PenggunaController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PenggunaState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PenggunaState>(value),
    );
  }
}

String _$penggunaControllerHash() =>
    r'26379316a33593d23af552546ced8aa945069cc8';

abstract class _$PenggunaController extends $Notifier<PenggunaState> {
  PenggunaState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PenggunaState, PenggunaState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PenggunaState, PenggunaState>,
              PenggunaState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
