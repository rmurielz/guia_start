import 'package:guia_start/domain/entities/entity.dart';

class Visitor extends Entity {
  @override
  final String id;
  final String participationId;
  final int count;
  final String? notes;
  final DateTime timestamp;

  Visitor({
    required this.id,
    required this.participationId,
    required this.count,
    this.notes,
    required this.timestamp,
  });

  @override
  Visitor copyWith({
    String? id,
    String? participationId,
    int? count,
    String? notes,
    DateTime? timestamp,
  }) {
    return Visitor(
      id: id ?? this.id,
      participationId: participationId ?? this.participationId,
      count: count ?? this.count,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  bool get hasNotes => notes != null && notes!.isNotEmpty;

  @override
  String toString() {
    return 'Visitor(id: $id, count: $count, timestamp: $timestamp)';
  }
}
