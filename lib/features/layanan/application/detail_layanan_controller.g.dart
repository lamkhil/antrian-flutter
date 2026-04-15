// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_layanan_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DetailLayananController)
final detailLayananControllerProvider = DetailLayananControllerProvider._();

final class DetailLayananControllerProvider
    extends $NotifierProvider<DetailLayananController, DetailLayananState> {
  DetailLayananControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'detailLayananControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$detailLayananControllerHash();

  @$internal
  @override
  DetailLayananController create() => DetailLayananController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DetailLayananState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DetailLayananState>(value),
    );
  }
}

String _$detailLayananControllerHash() =>
    r'bfc1357638bbe4a12cc63649f9d93ead8e0cf249';

abstract class _$DetailLayananController extends $Notifier<DetailLayananState> {
  DetailLayananState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DetailLayananState, DetailLayananState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DetailLayananState, DetailLayananState>,
              DetailLayananState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
