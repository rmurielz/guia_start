import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String thirdPartyId;
  final String? notes;
  final DateTime createdAt;

  Contact({
    required this.id,
    required this.thirdPartyId,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'thirdPartyId': thirdPartyId,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] ?? '',
      thirdPartyId: map['thirdPartyId'] ?? '',
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Contact copyWith({
    String? id,
    String? thirdPartyId,
    String? notes,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      thirdPartyId: thirdPartyId ?? this.thirdPartyId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
