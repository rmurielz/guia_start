import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/domain/entities/third_party.dart';

class ThirdPartyDto {
  final String id;
  final String name;
  final String type;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final String? notes;
  final String createdBy;
  final Timestamp createdAt;

  ThirdPartyDto({
    required this.id,
    required this.name,
    required this.type,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  /// Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'address': address,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  /// Crear desde Map de Firebase
  factory ThirdPartyDto.fromMap(Map<String, dynamic> map) {
    return ThirdPartyDto(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      contactEmail: map['contactEmail'],
      contactPhone: map['contactPhone'],
      address: map['address'],
      notes: map['notes'],
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  /// Convertir a Entity de dominio
  ThirdParty toEntity() {
    return ThirdParty(
      id: id,
      name: name,
      type: _parseType(type),
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      address: address,
      notes: notes,
      createdBy: createdBy,
      createdAt: createdAt.toDate(),
    );
  }

  /// Crear desde Entity de dominio
  factory ThirdPartyDto.fromEntity(ThirdParty entity) {
    return ThirdPartyDto(
      id: entity.id,
      name: entity.name,
      type: entity.type.name,
      contactEmail: entity.contactEmail,
      contactPhone: entity.contactPhone,
      address: entity.address,
      notes: entity.notes,
      createdBy: entity.createdBy,
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }

  static ThirdPartyType _parseType(String type) {
    return ThirdPartyType.values
        .firstWhere((e) => e.name == type, orElse: () => ThirdPartyType.other);
  }
}
