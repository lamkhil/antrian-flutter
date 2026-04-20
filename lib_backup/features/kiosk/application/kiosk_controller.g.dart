// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KioskController)
final kioskControllerProvider = KioskControllerProvider._();

final class KioskControllerProvider
    extends $NotifierProvider<KioskController, KioskState> {
  KioskControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kioskControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kioskControllerHash();

  @$internal
  @override
  KioskController create() => KioskController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KioskState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KioskState>(value),
    );
  }
}

String _$kioskControllerHash() => r'9bbfb2b29a931e3d7a71f5563861d984a3d970d2';

abstract class _$KioskController extends $Notifier<KioskState> {
  KioskState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<KioskState, KioskState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KioskState, KioskState>,
              KioskState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
