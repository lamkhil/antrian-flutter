// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengaturan_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PengaturanController)
final pengaturanControllerProvider = PengaturanControllerProvider._();

final class PengaturanControllerProvider
    extends $NotifierProvider<PengaturanController, User?> {
  PengaturanControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pengaturanControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pengaturanControllerHash();

  @$internal
  @override
  PengaturanController create() => PengaturanController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$pengaturanControllerHash() =>
    r'a83965158ecf5c16de6074c32790be51578dfe7d';

abstract class _$PengaturanController extends $Notifier<User?> {
  User? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<User?, User?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<User?, User?>,
              User?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
