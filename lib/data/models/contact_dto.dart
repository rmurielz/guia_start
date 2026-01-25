import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/domain/entities/contact.dart';

class ContactDTO {
  final String id;
  final String participationId;
  final String thirdPartyId;
  final String? notes;
  final Timestamp createdAt;

  ContactDTO({
    required this.id,
    required this.participationId,
    required this.thirdPartyId,
    this.notes,
    required this.createdAt,
  });

  /// Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'participationId': participationId,
      'thirdPartyId': thirdPartyId,
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  /// Crear desde Map de Firebase
  factory ContactDTO.fromMap(Map<String, dynamic> map) {
    return ContactDTO(
      id: map['id'] ?? '',
      participationId: map['participationId'] ?? '',
      thirdPartyId: map['thirdPartyId'] ?? '',
      notes: map['notes'],
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  /// Convertir a Entity de dominio
  Contact toEntity() {
    return Contact(
      id: id,
      participationId: participationId,
      thirdPartyId: thirdPartyId,
      notes: notes,
      createdAt: createdAt.toDate(),
    );
  }

  /// Crear desde Entity de dominio
  factory ContactDTO.fromEntity(Contact entity) {
    return ContactDTO(
      id: entity.id,
      participationId: entity.participationId,
      thirdPartyId: entity.thirdPartyId,
      notes: entity.notes,
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }
}
