import 'package:antrian/data/models/antrian.dart';
import 'package:antrian/data/models/loket.dart';
import 'package:antrian/data/models/zona.dart';
import 'package:antrian/data/services/antrian/antrian_services.dart';
import 'package:antrian/data/services/loket/loket_services.dart';
import 'package:antrian/data/services/zona/zona_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'display_controller.g.dart';

class DisplayData {
  final Zona? zona;
  final List<Loket> loketList;
  final List<Antrian> antrianAktif;

  const DisplayData({
    this.zona,
    this.loketList = const [],
    this.antrianAktif = const [],
  });

  /// Antrian yang sedang dipanggil/dilayani di loket tertentu (terbaru dulu).
  Antrian? currentAt(String loketId) {
    final matched = antrianAktif
        .where(
          (a) =>
              a.loketId == loketId &&
              (a.status == StatusAntrian.dipanggil ||
                  a.status == StatusAntrian.dilayani),
        )
        .toList();
    if (matched.isEmpty) return null;
    matched.sort(
      (a, b) => (b.waktuDipanggil ?? b.waktuDaftar)
          .compareTo(a.waktuDipanggil ?? a.waktuDaftar),
    );
    return matched.first;
  }

  /// Antrian menunggu di zona (urut lama → baru).
  List<Antrian> get antrianMenunggu {
    final list = antrianAktif
        .where((a) => a.status == StatusAntrian.menunggu)
        .toList();
    list.sort((a, b) => a.waktuDaftar.compareTo(b.waktuDaftar));
    return list;
  }
}

/// Stream real-time untuk layar display per zona.
/// Zona dan daftar loket di-fetch sekali; antrian distream dari Firestore.
@riverpod
Stream<DisplayData> displayData(Ref ref, String zonaId) async* {
  final zonaResult = await ZonaServices.fetchZonaById(zonaId);
  final zona = zonaResult.success ? zonaResult.data : null;
  final loketList = await _fetchLoketByZona(zonaId);

  await for (final antrian in AntrianServices.streamAktifByZona(zonaId)) {
    yield DisplayData(
      zona: zona,
      loketList: loketList,
      antrianAktif: antrian,
    );
  }
}

/// Ambil semua loket di sebuah zona dengan: cari layanan di zona,
/// lalu loket per layanan.
Future<List<Loket>> _fetchLoketByZona(String zonaId) async {
  final servicesSnap = await FirebaseFirestore.instance
      .collection('services')
      .where('zonaId', isEqualTo: zonaId)
      .get();
  final result = <Loket>[];
  for (final doc in servicesSnap.docs) {
    final r = await LoketServices.fetchByLayanan(doc.id);
    if (r.success && r.data != null) result.addAll(r.data!);
  }
  return result;
}
