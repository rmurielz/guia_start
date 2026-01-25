import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/domain/entities/edition.dart';

class EditionDTO {
  final String id;
  final String fairId;
  final String name;
  final String location;
  final Timestamp initDate;
  final Timestamp endDate;
  final String createdBy;
  final Timestamp createdAt;
  final String status;

  EditionDTO({
    required this.id,
    required this.fairId,
    required this.name,
    required this.location,
    required this.initDate,
    required this.endDate,
    required this.createdBy,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'fairId': fairId,
      'name': name,
      'location': location,
      'initDate': initDate,
      'endDate': endDate,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'status': status
    };
  }

  factory EditionDTO.fromMap(Map<String, dynamic> map) {
    return EditionDTO(
      id: map['id'] ?? '',
      fairId: map['fairId'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      initDate: map['initDate'] as Timestamp? ?? Timestamp.now(),
      endDate: map['endDate'] as Timestamp? ?? Timestamp.now(),
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      status: map['status'] ?? 'planning',
    );
  }

  /// Convertir a Entity de dominio
  Edition toEntity() {
    return Edition(
      id: id,
      fairId: fairId,
      name: name,
      location: location,
      initDate: initDate.toDate(),
      endDate: endDate.toDate(),
      createdBy: createdBy,
      createdAt: createdAt.toDate(),
      status: _parseStatus(status),
    );
  }

  /// Crear desde Entity de dominio
  factory EditionDTO.fromEntity(Edition entity) {
    return EditionDTO(
      id: entity.id,
      fairId: entity.fairId,
      name: entity.name,
      location: entity.location,
      initDate: Timestamp.fromDate(entity.initDate),
      endDate: Timestamp.fromDate(entity.endDate),
      createdBy: entity.createdBy,
      createdAt: Timestamp.fromDate(entity.createdAt),
      status: entity.status.name,
    );
  }

  static EditionStatus _parseStatus(String status) {
    return EditionStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => EditionStatus.planning,
    );
  }
}
