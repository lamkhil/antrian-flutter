// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream real-time untuk layar display per zona.
/// Zona dan daftar loket di-fetch sekali; antrian distream dari Firestore.

@ProviderFor(displayData)
final displayDataProvider = DisplayDataFamily._();

/// Stream real-time untuk layar display per zona.
/// Zona dan daftar loket di-fetch sekali; antrian distream dari Firestore.

final class DisplayDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<DisplayData>,
          DisplayData,
          Stream<DisplayData>
        >
    with $FutureModifier<DisplayData>, $StreamProvider<DisplayData> {
  /// Stream real-time untuk layar display per zona.
  /// Zona dan daftar loket di-fetch sekali; antrian distream dari Firestore.
  DisplayDataProvider._({
    required DisplayDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'displayDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$displayDataHash();

  @override
  String toString() {
    return r'displayDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DisplayData> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DisplayData> create(Ref ref) {
    final argument = this.argument as String;
    return displayData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DisplayDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$displayDataHash() => r'f0c1018badc3987a5f12e60403483d23643be938';

/// Stream real-time untuk layar display per zona.
/// Zona dan daftar loket di-fetch sekali; antrian distream dari Firestore.

final class DisplayDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DisplayData>, String> {
  DisplayDataFamily._()
    : super(
        retry: null,
        name: r'displayDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream real-time untuk layar display per zona.
  /// Zona dan daftar loket di-fetch sekali; antrian distream dari Firestore.

  DisplayDataProvider call(String zonaId) =>
      DisplayDataProvider._(argument: zonaId, from: this);

  @override
  String toString() => r'displayDataProvider';
}
