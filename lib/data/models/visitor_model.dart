import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/utils/entity.dart';

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
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'participationId': participationId,
      'count': count,
      'notes': notes,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Visitor.fromMap(Map<String, dynamic> map) {
    return Visitor(
      id: map['id'] ?? '',
      participationId: map['participationId'] ?? '',
      count: map['count'] ?? 1,
      notes: map['notes'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
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

  @override
  String toString() {
    return 'Visitor(id: $id, count: $count, timestamp: $timestamp, participation: $participationId)';
  }
}
