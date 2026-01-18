import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/utils/entity.dart';

class Participation extends Entity {
  @override
  final String id;
  final String userId;
  final String fairId;
  final String editionId;
  final String? boothNumber;
  final double participationCost;
  final DateTime createdAt;

  Participation({
    required this.id,
    required this.userId,
    required this.fairId,
    required this.editionId,
    this.boothNumber,
    required this.participationCost,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fairId': fairId,
      'editionId': editionId,
      'boothNumber': boothNumber,
      'participationCost': participationCost,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Participation.fromMap(Map<String, dynamic> map) {
    return Participation(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      fairId: map['fairId'] ?? '',
      editionId: map['editionId'] ?? '',
      boothNumber: map['boothNumber'],
      participationCost: map['participationCost']?.toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  @override
  Participation copyWith({
    String? id,
    String? userId,
    String? fairId,
    String? editionId,
    String? boothNumber,
    double? participationCost,
    DateTime? createdAt,
  }) {
    return Participation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fairId: fairId ?? this.fairId,
      editionId: editionId ?? this.editionId,
      boothNumber: boothNumber ?? this.boothNumber,
      participationCost: participationCost ?? this.participationCost,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Participation(id: $id, fairId: $fairId, editionId: $editionId, participationCost: $participationCost)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Participation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  bool get hasBoothAssigned => boothNumber != null && boothNumber!.isNotEmpty;

  bool get isFree => participationCost == 0.0;
}
