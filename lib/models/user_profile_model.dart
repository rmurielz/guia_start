import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/utils/entity.dart';

class UserProfile extends Entity {
  @override
  final String id;
  final String name;
  final String email;
  final String? businessName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.businessName,
    this.photoUrl,
    DateTime? createdAt,
    this.lastLoginAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convertir en Map para firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'businessName': businessName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  // Crear desde Map de Firestore
  @override
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      businessName: map['businessName'],
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  // Copiar con cambios
  @override
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? businessName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      businessName: businessName ?? this.businessName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

//Helper: Obtener nombre de usuario para mostrar
  String get displayName {
    if (businessName != null && businessName!.isNotEmpty) {
      return '$name ($businessName)';
    }
    return name;
  }

//Helper: Veriificar si tiene negocio configurado
  bool get hasBusiness => businessName != null && businessName!.isNotEmpty;
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
}
