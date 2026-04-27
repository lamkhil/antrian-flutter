import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final String id;
  final String name;
  final String zoneId;
  final String? code;
  final DateTime? createdAt;

  const Service({
    required this.id,
    required this.name,
    required this.zoneId,
    this.code,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'zoneId': zoneId,
        'code': code,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      };

  factory Service.fromMap(Map<String, dynamic> map) {
    final raw = map['createdAt'];
    DateTime? created;
    if (raw is Timestamp) created = raw.toDate();
    if (raw is DateTime) created = raw;
    return Service(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      zoneId: map['zoneId']?.toString() ?? '',
      code: map['code']?.toString(),
      createdAt: created,
    );
  }

  @override
  List<Object?> get props => [id];
}
