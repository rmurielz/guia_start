import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/domain/entities/fair.dart';

/// DTO para Fair - maneja conversión entre Firebase y Domain
class FairDTO {
  final String id;
  final String name;
  final String description;
  final String organizerId;
  final String createdBy;
  final bool isRecurring;
  final Timestamp createdAt;

  FairDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.organizerId,
    required this.createdBy,
    required this.isRecurring,
    required this.createdAt,
  });

  /// Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'organizerId': organizerId,
      'createdBy': createdBy,
      'isRecurring': isRecurring,
      'createdAt': createdAt,
    };
  }

  /// Crear desde Map de Firebase
  factory FairDTO.fromMap(Map<String, dynamic> map) {
    return FairDTO(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      organizerId: map['organizerId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      isRecurring: map['isRecurring'] ?? false,
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  /// Convertir a Entity de dominio
  Fair toEntity() {
    return Fair(
      id: id,
      name: name,
      description: description,
      organizerId: organizerId,
      createdBy: createdBy,
      isRecurring: isRecurring,
      createdAt: createdAt.toDate(),
    );
  }

  /// Crear desde Entity de dominio
  factory FairDTO.fromEntity(Fair entity) {
    return FairDTO(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      organizerId: entity.organizerId,
      createdBy: entity.createdBy,
      isRecurring: entity.isRecurring,
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }
}
