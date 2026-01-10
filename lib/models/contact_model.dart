import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/utils/entity.dart';

class Contact extends Entity {
  @override
  final String id;
  final String participationId;
  final String thirdPartyId;
  final String? notes;
  final DateTime createdAt;

  Contact({
    required this.id,
    required this.participationId,
    required this.thirdPartyId,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'participationId': participationId,
      'thirdPartyId': thirdPartyId,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] ?? '',
      participationId: map['participationId'] ?? '',
      thirdPartyId: map['thirdPartyId'] ?? '',
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  @override
  Contact copyWith({
    String? id,
    String? participantId,
    String? thirdPartyId,
    String? notes,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      participationId: participationId ?? this.participationId,
      thirdPartyId: thirdPartyId ?? this.thirdPartyId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Contact(id: $id, thirdPartyId: $thirdPartyId, participation: $participationId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Contact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
  bool get hasNotes => notes != null && notes!.isNotEmpty;
}
