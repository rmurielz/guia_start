import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/domain/entities/participation.dart';

class ParticipationDTO {
  final String id;
  final String userId;
  final String fairId;
  final String editionId;
  final String? boothNumber;
  final double participationCost;
  final Timestamp createdAt;

  ParticipationDTO({
    required this.id,
    required this.userId,
    required this.fairId,
    required this.editionId,
    this.boothNumber,
    required this.participationCost,
    required this.createdAt,
  });

  /// Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fairId': fairId,
      'editionId': editionId,
      'boothNumber': boothNumber,
      'participationCost': participationCost,
      'createdAt': createdAt,
    };
  }

  /// Crear desde Map de Firebase
  factory ParticipationDTO.fromMap(Map<String, dynamic> map) {
    return ParticipationDTO(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      fairId: map['fairId'] ?? '',
      editionId: map['editionId'] ?? '',
      boothNumber: map['boothNumber'],
      participationCost: (map['participationCost'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  /// Convertir a Entity de dominio
  Participation toEntity() {
    return Participation(
      id: id,
      userId: userId,
      fairId: fairId,
      editionId: editionId,
      boothNumber: boothNumber,
      participationCost: participationCost,
      createdAt: createdAt.toDate(),
    );
  }

  /// Crear desde Entity de dominio
  factory ParticipationDTO.fromEntity(Participation entity) {
    return ParticipationDTO(
      id: entity.id,
      userId: entity.userId,
      fairId: entity.fairId,
      editionId: entity.editionId,
      boothNumber: entity.boothNumber,
      participationCost: entity.participationCost,
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }
}
