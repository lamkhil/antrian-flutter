import 'package:antrian/data/models/pengguna.dart';
import 'package:antrian/data/models/response_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PenggunaServices {
  static Future<ResponseApi<List<Pengguna>>> fetchAll() async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .get();

      final list = result.docs
          .map((e) => Pengguna.fromJson(e.data()))
          .toList();

      return ResponseApi(data: list);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<Pengguna?>> add(Pengguna newPengguna) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newPengguna.id)
          .set(newPengguna.toJson());

      return ResponseApi(data: newPengguna);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<Pengguna?>> update(Pengguna updated) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updated.id)
          .update(updated.toJson());

      return ResponseApi(data: updated);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }

  static Future<ResponseApi<void>> delete(String id) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(id).delete();
      return ResponseApi(data: null);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }
}
