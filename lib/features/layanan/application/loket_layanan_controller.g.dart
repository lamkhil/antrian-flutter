// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loket_layanan_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoketLayananController)
final loketLayananControllerProvider = LoketLayananControllerProvider._();

final class LoketLayananControllerProvider
    extends $NotifierProvider<LoketLayananController, LoketLayananState> {
  LoketLayananControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loketLayananControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loketLayananControllerHash();

  @$internal
  @override
  LoketLayananController create() => LoketLayananController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoketLayananState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoketLayananState>(value),
    );
  }
}

String _$loketLayananControllerHash() =>
    r'868593a0215375ccdc522caf132bdb0ac8ca2528';

abstract class _$LoketLayananController extends $Notifier<LoketLayananState> {
  LoketLayananState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LoketLayananState, LoketLayananState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoketLayananState, LoketLayananState>,
              LoketLayananState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
