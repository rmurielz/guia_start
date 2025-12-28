import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
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

//Helper: Obtener nombre de usuario para mostrar
  String get displayName {
    if (businessName != null && businessName!.isNotEmpty) {
      return '$name ($businessName)';
    }
    return name;
  }

//Helper: Veriificar si tiene negocio configurado
  bool get hasBusiness => businessName != null && businessName!.isNotEmpty;
}
