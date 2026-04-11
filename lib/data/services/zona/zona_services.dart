import 'package:antrian/data/models/layanan.dart';
import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/data/models/response_api.dart';
import 'package:antrian/data/models/zona.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ZonaServices {
  static Future<ResponseApi<List<Zona>>> fetchZona({
    Lokasi? lokasi,
    String? nama,
  }) async {
    try {
      Query query = FirebaseFirestore.instance.collection('zones');

      if (lokasi != null) {
        query = query.where('lokasiId', isEqualTo: lokasi.id);
      }

      if (nama != null) {
        query = query.where('nama', isGreaterThanOrEqualTo: nama);
      }

      final result = await query.get();

      final zonaList = result.docs
          .map((e) => Zona.fromJson(e.data() as Map<String, dynamic>))
          .toList();

      return ResponseApi(data: zonaList);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<Zona?>> addZona(Zona newZona) async {
    try {
      await FirebaseFirestore.instance
          .collection('zones')
          .doc(newZona.id)
          .set(newZona.toJson());

      return ResponseApi(data: newZona);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<Zona?>> updateZona(Zona updatedZona) async {
    try {
      await FirebaseFirestore.instance
          .collection('zones')
          .doc(updatedZona.id)
          .update(updatedZona.toJson());

      return ResponseApi(data: updatedZona);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<void>> deleteZona(String id) async {
    try {
      await FirebaseFirestore.instance.collection('zones').doc(id).delete();
      return ResponseApi(data: null);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<Zona?>> fetchZonaById(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('zones')
          .doc(id)
          .get();

      if (!doc.exists) {
        return ResponseApi.error("Zona tidak ditemukan");
      }

      final zona = Zona.fromJson(doc.data() as Map<String, dynamic>);
      return ResponseApi(data: zona);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<List<Layanan>>> fetchLayananByZona(
    String zonaId,
  ) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('zonaId', isEqualTo: zonaId)
          .get();

      final layananList = querySnapshot.docs
          .map((doc) => Layanan.fromJson(doc.data()))
          .toList();

      return ResponseApi(data: layananList);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<Layanan>> addLayanan(Layanan newLayanan) async {
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

  static Future<ResponseApi<List<Layanan>>> fetchLayananByLokasi(
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

  static Future<ResponseApi<Layanan?>> tambahLayanan(Layanan newLayanan) async {
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

  static Future<ResponseApi<Layanan?>> editLayanan(
    Layanan updatedLayanan,
  ) async {
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
}
