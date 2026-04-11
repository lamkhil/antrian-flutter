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
    extends $NotifierProvider<AntrianController, int> {
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
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$antrianControllerHash() => r'2dc3efb5ee689e2e96176df034530f289a041c9c';

abstract class _$AntrianController extends $Notifier<int> {
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
