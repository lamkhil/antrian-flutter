import 'package:antrian/data/models/pengguna.dart';
import 'package:antrian/data/models/response_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PenggunaServices {
  @visibleForTesting
  static FirebaseFirestore db = FirebaseFirestore.instance;

  static Future<ResponseApi<List<Pengguna>>> fetchAll() async {
    try {
      final result = await db.collection('users').get();

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
      await db
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
      await db
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
      await db.collection('users').doc(id).delete();
      return ResponseApi(data: null);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }
}
