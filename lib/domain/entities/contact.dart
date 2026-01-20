import 'package:guia_start/domain/entities/entity.dart';

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
    required this.createdAt,
  });

  @override
  Contact copyWith({
    String? id,
    String? participationId,
    String? thirdPArtyId,
    String? notes,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      participationId: participationId ?? this.participationId,
      thirdPartyId: thirdPArtyId ?? this.thirdPartyId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get hasNotes => notes != null && notes!.isNotEmpty;

  @override
  String toString() {
    return 'Contact(id: $id, thirdpartyId: $thirdPartyId)';
  }
}
