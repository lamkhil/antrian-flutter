import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Counter extends Equatable {
  final String id;
  final String name;
  final List<String> serviceIds;
  final DateTime? createdAt;

  const Counter({
    required this.id,
    required this.name,
    this.serviceIds = const [],
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'serviceIds': serviceIds,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      };

  factory Counter.fromMap(Map<String, dynamic> map) {
    final raw = map['createdAt'];
    DateTime? created;
    if (raw is Timestamp) created = raw.toDate();
    if (raw is DateTime) created = raw;
    final services = (map['serviceIds'] as List?)
            ?.map((e) => e.toString())
            .toList(growable: false) ??
        const <String>[];
    return Counter(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      serviceIds: services,
      createdAt: created,
    );
  }

  @override
  List<Object?> get props => [id];
}
