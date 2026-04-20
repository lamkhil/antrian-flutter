import 'package:equatable/equatable.dart';

class Lokasi extends Equatable {
  final String id;
  final String nama;
  final String alamat;

  const Lokasi({required this.id, required this.nama, required this.alamat});

  Lokasi copyWith({String? nama, String? alamat}) =>
      Lokasi(id: id, nama: nama ?? this.nama, alamat: alamat ?? this.alamat);

  factory Lokasi.fromJson(Map<String, dynamic> json) =>
      Lokasi(id: json['id'], nama: json['nama'], alamat: json['alamat']);

  Map<String, dynamic> toJson() => {'id': id, 'nama': nama, 'alamat': alamat};

  @override
  List<Object?> get props => [id];
}
