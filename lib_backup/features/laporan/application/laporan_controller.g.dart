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
    extends $NotifierProvider<LaporanController, LaporanState> {
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
  Override overrideWithValue(LaporanState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LaporanState>(value),
    );
  }
}

String _$laporanControllerHash() => r'567a22947c2465e958926a7b7e7be90608557bcb';

abstract class _$LaporanController extends $Notifier<LaporanState> {
  LaporanState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LaporanState, LaporanState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LaporanState, LaporanState>,
              LaporanState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
