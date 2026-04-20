import 'package:antrian/data/models/layanan.dart';
import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/data/models/response_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LayananServices {
  static Future<ResponseApi<Layanan?>> fetchById(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('services')
          .doc(id)
          .get();

      if (!doc.exists) {
        return ResponseApi.error('Layanan tidak ditemukan');
      }

      final layanan = Layanan.fromJson(doc.data()!);
      return ResponseApi(data: layanan);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<List<Layanan>>> fetchByZona(String zonaId) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('services')
          .where('zonaId', isEqualTo: zonaId)
          .get();

      final layananList = result.docs
          .map((doc) => Layanan.fromJson(doc.data()))
          .toList();

      return ResponseApi(data: layananList);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<List<Layanan>>> fetchByLokasi(
    Lokasi? lokasi,
  ) async {
    try {
      Query query = FirebaseFirestore.instance.collection('services');

      if (lokasi != null) {
        query = query.where('lokasiId', isEqualTo: lokasi.id);
      }

      final result = await query.get();

      final layananList = result.docs
          .map((e) => Layanan.fromJson(e.data() as Map<String, dynamic>))
          .toList();

      return ResponseApi(data: layananList);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<Layanan?>> add(Layanan newLayanan) async {
    try {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(newLayanan.id)
          .set(newLayanan.toJson());

      return ResponseApi(data: newLayanan);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<Layanan?>> update(Layanan updatedLayanan) async {
    try {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(updatedLayanan.id)
          .update(updatedLayanan.toJson());

      return ResponseApi(data: updatedLayanan);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<void>> delete(String id) async {
    try {
      await FirebaseFirestore.instance.collection('services').doc(id).delete();
      return ResponseApi(data: null);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }
}
