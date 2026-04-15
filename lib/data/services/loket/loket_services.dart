import 'package:antrian/data/models/loket.dart';
import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/data/models/response_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoketServices {
  static Future<ResponseApi<List<Loket>>> fetchByLayanan(
    String layananId,
  ) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('counters')
          .where('layananId', isEqualTo: layananId)
          .get();

      final loketList = result.docs
          .map((doc) => Loket.fromJson(doc.data()))
          .toList();

      return ResponseApi(data: loketList);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<List<Loket>>> fetchByLokasi(Lokasi? lokasi) async {
    try {
      Query query = FirebaseFirestore.instance.collection('counters');

      if (lokasi != null) {
        query = query.where('lokasiId', isEqualTo: lokasi.id);
      }

      final result = await query.get();

      final loketList = result.docs
          .map((e) => Loket.fromJson(e.data() as Map<String, dynamic>))
          .toList();

      return ResponseApi(data: loketList);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<Loket?>> add(Loket newLoket) async {
    try {
      await FirebaseFirestore.instance
          .collection('counters')
          .doc(newLoket.id)
          .set(newLoket.toJson());

      return ResponseApi(data: newLoket);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<Loket?>> update(Loket updatedLoket) async {
    try {
      await FirebaseFirestore.instance
          .collection('counters')
          .doc(updatedLoket.id)
          .update(updatedLoket.toJson());

      return ResponseApi(data: updatedLoket);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<void>> delete(String id) async {
    try {
      await FirebaseFirestore.instance.collection('counters').doc(id).delete();
      return ResponseApi(data: null);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }
}
