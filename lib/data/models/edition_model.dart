import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/utils/entity.dart';

class Edition extends Entity {
  @override
  final String id;
  final String fairId;
  final String name;
  final String location;
  final DateTime initDate;
  final DateTime endDate;
  final String createdBy;
  final DateTime createdAt;
  final String status;

  Edition({
    required this.id,
    required this.fairId,
    required this.name,
    required this.location,
    required this.initDate,
    required this.endDate,
    required this.createdBy,
    DateTime? createdAt,
    String? status,
  })  : createdAt = createdAt ?? DateTime.now(),
        status = status ?? 'planning';

  Map<String, dynamic> toMap() {
    return {
      'fairId': fairId,
      'name': name,
      'location': location,
      'initDate': Timestamp.fromDate(initDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  factory Edition.fromMap(Map<String, dynamic> map) {
    return Edition(
      id: map['id'] ?? '',
      fairId: map['fairId'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      initDate: (map['initDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'planning',
    );
  }

  @override
  Edition copyWith({
    String? id,
    String? fairId,
    String? name,
    String? location,
    DateTime? initDate,
    DateTime? endDate,
    String? createdBy,
    DateTime? createdAt,
    String? status,
  }) {
    return Edition(
      id: id ?? this.id,
      fairId: fairId ?? this.fairId,
      name: name ?? this.name,
      location: location ?? this.location,
      initDate: initDate ?? this.initDate,
      endDate: endDate ?? this.endDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  bool get isPlanning => status == 'planning';
  bool get isActive => status == 'active';
  bool get isFinished => status == 'finished';

  bool get canEdit => isPlanning;
  bool get canRegisterSales => isActive;
  bool get canExport => isFinished;
}
