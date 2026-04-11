// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'antrian_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AntrianController)
final antrianControllerProvider = AntrianControllerProvider._();

final class AntrianControllerProvider
    extends $NotifierProvider<AntrianController, AntrianState> {
  AntrianControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'antrianControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$antrianControllerHash();

  @$internal
  @override
  AntrianController create() => AntrianController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AntrianState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AntrianState>(value),
    );
  }
}

String _$antrianControllerHash() => r'e0dcd35b480b505adbeb2f792c6cb7925ec09fb0';

abstract class _$AntrianController extends $Notifier<AntrianState> {
  AntrianState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AntrianState, AntrianState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AntrianState, AntrianState>,
              AntrianState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
