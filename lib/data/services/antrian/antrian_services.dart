import 'package:antrian/data/models/antrian.dart';
import 'package:antrian/data/models/layanan.dart';
import 'package:antrian/data/models/response_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AntrianServices {
  static final _db = FirebaseFirestore.instance;

  /// Generate nomor antrian sekuensial per layanan per hari.
  /// Format: `<huruf_pertama_kode_layanan>-<3 digit>`, contoh "L-001".
  static Future<ResponseApi<Antrian?>> ambilTiket(Layanan layanan) async {
    try {
      final now = DateTime.now();
      final dari = DateTime(now.year, now.month, now.day);
      final sampai = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final existing = await _db
          .collection('antrians')
          .where('layananId', isEqualTo: layanan.id)
          .where('waktuDaftar', isGreaterThanOrEqualTo: Timestamp.fromDate(dari))
          .where(
            'waktuDaftar',
            isLessThanOrEqualTo: Timestamp.fromDate(sampai),
          )
          .get();

      final seq = existing.docs.length + 1;
      final prefix = layanan.kode.isNotEmpty
          ? layanan.kode.substring(0, 1).toUpperCase()
          : 'X';
      final nomor = '$prefix-${seq.toString().padLeft(3, '0')}';

      final id = _db.collection('antrians').doc().id;
      final antrian = Antrian(
        id: id,
        nomorAntrian: nomor,
        nama: '',
        layananId: layanan.id,
        zonaId: layanan.zonaId,
        lokasiId: layanan.lokasiId,
        status: StatusAntrian.menunggu,
        waktuDaftar: now,
        layanan: layanan,
        zona: layanan.zona,
        lokasi: layanan.lokasi,
      );

      await _db.collection('antrians').doc(id).set({
        ...antrian.toJson(),
        'waktuDaftar': Timestamp.fromDate(now),
      });

      return ResponseApi(data: antrian);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  /// Stream antrian aktif (menunggu/dipanggil/dilayani) di satu zona.
  /// Dipakai oleh display layar zona.
  static Stream<List<Antrian>> streamAktifByZona(String zonaId) {
    return _db
        .collection('antrians')
        .where('zonaId', isEqualTo: zonaId)
        .where(
          'status',
          whereIn: [
            StatusAntrian.menunggu.name,
            StatusAntrian.dipanggil.name,
            StatusAntrian.dilayani.name,
          ],
        )
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => Antrian.fromJson(d.data())).toList(),
        );
  }
}
