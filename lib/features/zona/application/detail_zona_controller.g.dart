// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_zona_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DetailZonaController)
final detailZonaControllerProvider = DetailZonaControllerProvider._();

final class DetailZonaControllerProvider
    extends $NotifierProvider<DetailZonaController, DetailZonaState> {
  DetailZonaControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'detailZonaControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$detailZonaControllerHash();

  @$internal
  @override
  DetailZonaController create() => DetailZonaController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DetailZonaState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DetailZonaState>(value),
    );
  }
}

String _$detailZonaControllerHash() =>
    r'f7b055606a59dfcbd329fc14d5fd1c19b3a438c2';

abstract class _$DetailZonaController extends $Notifier<DetailZonaState> {
  DetailZonaState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DetailZonaState, DetailZonaState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DetailZonaState, DetailZonaState>,
              DetailZonaState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
