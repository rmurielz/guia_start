import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/domain/entities/user_profile.dart';

class UserProfileDTO {
  final String id;
  final String name;
  final String email;
  final String? businessName;
  final String? photoUrl;
  final Timestamp createdAt;
  final Timestamp? lastLoginAt;

  UserProfileDTO({
    required this.id,
    required this.name,
    required this.email,
    this.businessName,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'businessName': businessName,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
    };
  }

  /// Crear desde Map de Firebase
  factory UserProfileDTO.fromMap(Map<String, dynamic> map) {
    return UserProfileDTO(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      businessName: map['businessName'],
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      lastLoginAt: map['lastLoginAt'] as Timestamp?,
    );
  }

  /// Convertir a Entity de dominio
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      businessName: businessName,
      photoUrl: photoUrl,
      createdAt: createdAt.toDate(),
      lastLoginAt: lastLoginAt?.toDate(),
    );
  }

  /// Crear desde Entity de dominio
  factory UserProfileDTO.fromEntity(UserProfile entity) {
    return UserProfileDTO(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      businessName: entity.businessName,
      photoUrl: entity.photoUrl,
      createdAt: Timestamp.fromDate(entity.createdAt),
      lastLoginAt: entity.lastLoginAt != null
          ? Timestamp.fromDate(entity.lastLoginAt!)
          : null,
    );
  }
}
