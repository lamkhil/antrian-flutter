// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laporan_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LaporanController)
final laporanControllerProvider = LaporanControllerProvider._();

final class LaporanControllerProvider
    extends $NotifierProvider<LaporanController, int> {
  LaporanControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'laporanControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$laporanControllerHash();

  @$internal
  @override
  LaporanController create() => LaporanController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$laporanControllerHash() => r'ddaf598e921400ec0f69d9d9b39001e4bb357a43';

abstract class _$LaporanController extends $Notifier<int> {
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
