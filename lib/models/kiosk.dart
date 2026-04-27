import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Kiosk extends Equatable {
  final String id;
  final String name;
  final String deviceId;
  final bool active;
  final DateTime? createdAt;

  const Kiosk({
    required this.id,
    required this.name,
    required this.deviceId,
    this.active = true,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'deviceId': deviceId,
        'active': active,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      };

  factory Kiosk.fromMap(Map<String, dynamic> map) {
    final raw = map['createdAt'];
    DateTime? created;
    if (raw is Timestamp) created = raw.toDate();
    if (raw is DateTime) created = raw;
    return Kiosk(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      deviceId: map['deviceId']?.toString() ?? '',
      active: (map['active'] as bool?) ?? true,
      createdAt: created,
    );
  }

  @override
  List<Object?> get props => [id];
}
