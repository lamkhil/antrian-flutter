// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lokasi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LokasiController)
final lokasiControllerProvider = LokasiControllerProvider._();

final class LokasiControllerProvider
    extends $NotifierProvider<LokasiController, LokasiState> {
  LokasiControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lokasiControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lokasiControllerHash();

  @$internal
  @override
  LokasiController create() => LokasiController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LokasiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LokasiState>(value),
    );
  }
}

String _$lokasiControllerHash() => r'c44fe19f64f3c8d6c9163d7bd96159ef38cc021e';

abstract class _$LokasiController extends $Notifier<LokasiState> {
  LokasiState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LokasiState, LokasiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LokasiState, LokasiState>,
              LokasiState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
