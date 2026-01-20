import 'package:guia_start/domain/entities/entity.dart';

class UserProfile extends Entity {
  @override
  final String id;
  final String name;
  final String email;
  final String? businessName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.businessName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
  });

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

// Business logic

  String get displayName {
    if (businessName != null && businessName!.isNotEmpty) {
      return '$name ($businessName)';
    }
    return name;
  }

  bool get hasBusiness => businessName != null && businessName!.isNotEmpty;
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email)';
  }
}
