import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Zone extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;

  const Zone({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      };

  factory Zone.fromMap(Map<String, dynamic> map) {
    final raw = map['createdAt'];
    DateTime? created;
    if (raw is Timestamp) created = raw.toDate();
    if (raw is DateTime) created = raw;
    return Zone(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      createdAt: created,
    );
  }

  @override
  List<Object?> get props => [id];
}
