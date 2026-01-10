import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/utils/entity.dart';

// Modelo que representa una feria o evento comercial

class Fair extends Entity {
  @override
  final String id;
  final String name;
  final String description;
  final String organizerId;
  final String organizerName;
  final String createdBy;
  final bool isRecurring;
  final DateTime createdAt;

  Fair({
    required this.id,
    required this.name,
    required this.description,
    required this.organizerId,
    required this.organizerName,
    required this.createdBy,
    required this.isRecurring,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'createdBy': createdBy,
      'isRecurring': isRecurring,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Fair.fromMap(
    Map<String, dynamic> data,
  ) {
    return Fair(
      id: data['id'] as String? ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      createdBy: data['createdBy'] ?? '',
      isRecurring: data['isRecurring'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Fair copyWith({
    String? id,
    String? name,
    String? description,
    String? organizerId,
    String? organizerName,
    String? createdBy,
    bool? isRecurring,
    DateTime? createdAt,
  }) {
    return Fair(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      createdBy: createdBy ?? this.createdBy,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Fair{id: $id, name: $name, organizer: $organizerName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Fair && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
