import 'package:antrian/data/models/antrian.dart';
import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/data/models/response_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class LaporanServices {
  @visibleForTesting
  static FirebaseFirestore db = FirebaseFirestore.instance;

  static Future<ResponseApi<List<Antrian>>> fetchAntrianRange({
    required DateTime dari,
    required DateTime sampai,
    Lokasi? lokasi,
  }) async {
    try {
      Query query = db
          .collection('antrians')
          .where(
            'waktuDaftar',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dari),
          )
          .where(
            'waktuDaftar',
            isLessThanOrEqualTo: Timestamp.fromDate(sampai),
          );

      if (lokasi != null) {
        query = query.where('lokasiId', isEqualTo: lokasi.id);
      }

      final result = await query.get();
      final list = result.docs
          .map((e) => Antrian.fromJson(e.data() as Map<String, dynamic>))
          .toList();

      return ResponseApi(data: list);
    } catch (e) {
      return ResponseApi.error(e.toString());
    }
  }
}
