import 'package:cloud_firestore/cloud_firestore.dart';

class Visitor {
  final String id;
  final int count;
  final String? notes;
  final DateTime timestamp;

  Visitor({
    required this.id,
    required this.count,
    this.notes,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'count': count,
      'notes': notes,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Visitor.fromMap(Map<String, dynamic> map) {
    return Visitor(
      id: map['id'] ?? '',
      count: map['count'] ?? 1,
      notes: map['notes'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Visitor copyWith({
    String? id,
    int? count,
    String? notes,
    DateTime? timestamp,
  }) {
    return Visitor(
      id: id ?? this.id,
      count: count ?? this.count,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
