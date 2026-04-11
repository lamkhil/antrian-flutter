// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lokasi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LokasiProvider)
final lokasiProviderProvider = LokasiProviderProvider._();

final class LokasiProviderProvider
    extends $NotifierProvider<LokasiProvider, Lokasi?> {
  LokasiProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lokasiProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lokasiProviderHash();

  @$internal
  @override
  LokasiProvider create() => LokasiProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Lokasi? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Lokasi?>(value),
    );
  }
}

String _$lokasiProviderHash() => r'67fa1745a181f7cc5f30d979e8750f3b68518c1c';

abstract class _$LokasiProvider extends $Notifier<Lokasi?> {
  Lokasi? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Lokasi?, Lokasi?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Lokasi?, Lokasi?>,
              Lokasi?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
