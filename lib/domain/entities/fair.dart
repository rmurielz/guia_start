import 'package:guia_start/domain/entities/entity.dart';

class Fair extends Entity {
  @override
  final String id;
  final String name;
  final String description;
  final String organizerId;
  final String createdBy;
  final bool isRecurring;
  final DateTime createdAt;

  Fair({
    required this.id,
    required this.name,
    required this.description,
    required this.organizerId,
    required this.createdBy,
    required this.isRecurring,
    required this.createdAt,
  });

  @override
  Fair copyWith({
    String? id,
    String? name,
    String? description,
    String? organizerId,
    String? createdBy,
    bool? isRecurring,
    DateTime? createdAt,
  }) {
    return Fair(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      organizerId: organizerId ?? this.organizerId,
      createdBy: createdBy ?? this.createdBy,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Fair(id: $id, name; $name, organizer: $organizerId)';
  }
}
