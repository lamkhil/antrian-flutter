import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/data/models/response_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LokasiServices {
  static Future<ResponseApi<List<Lokasi>>> fetchLokasi() async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('locations')
          .get();
      final data = result.docs.map((e) => e.data()).toList();
      final lokasiList = data.map((e) => Lokasi.fromJson(e)).toList();
      return ResponseApi(data: lokasiList);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<Lokasi>> fetchLokasiById(String id) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('locations')
          .doc(id)
          .get();
      if (!result.exists) {
        return ResponseApi.error('Lokasi tidak ditemukan');
      }
      final data = result.data()!;
      final lokasi = Lokasi.fromJson(data);
      return ResponseApi(data: lokasi);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }
}
