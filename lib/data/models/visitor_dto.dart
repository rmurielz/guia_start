import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/domain/entities/visitor.dart';

class VisitorDTO {
  final String id;
  final String participationId;
  final int count;
  final String? notes;
  final Timestamp timestamp;

  VisitorDTO({
    required this.id,
    required this.participationId,
    required this.count,
    this.notes,
    required this.timestamp,
  });

  /// Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'participationId': participationId,
      'count': count,
      'notes': notes,
      'timestamp': timestamp,
    };
  }

  /// Crear desde Map de Firebase
  factory VisitorDTO.fromMap(Map<String, dynamic> map) {
    return VisitorDTO(
      id: map['id'] ?? '',
      participationId: map['participationId'] ?? '',
      count: map['count'] ?? 1,
      notes: map['notes'],
      timestamp: map['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }

  /// Convertir a Entity de dominio
  Visitor toEntity() {
    return Visitor(
      id: id,
      participationId: participationId,
      count: count,
      notes: notes,
      timestamp: timestamp.toDate(),
    );
  }

  /// Crear desde Entity de dominio
  factory VisitorDTO.fromEntity(Visitor entity) {
    return VisitorDTO(
      id: entity.id,
      participationId: entity.participationId,
      count: entity.count,
      notes: entity.notes,
      timestamp: Timestamp.fromDate(entity.timestamp),
    );
  }
}
