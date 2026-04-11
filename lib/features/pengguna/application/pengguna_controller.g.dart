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
    extends $NotifierProvider<PenggunaController, int> {
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
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$penggunaControllerHash() =>
    r'c991e84d3f00ef66c7b67842d39a1bbfe5987ea7';

abstract class _$PenggunaController extends $Notifier<int> {
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
