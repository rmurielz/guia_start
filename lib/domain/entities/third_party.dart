import 'package:guia_start/domain/entities/entity.dart';

class ThirdParty extends Entity {
  @override
  final String id;
  final String name;
  final ThirdPartyType type;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;

  ThirdParty({
    required this.id,
    required this.name,
    required this.type,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  ThirdParty copyWith({
    String? id,
    String? name,
    ThirdPartyType? type,
    String? contactEmail,
    String? contactPhone,
    String? address,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return ThirdParty(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

// Business logic
  String get typeLabel {
    switch (type) {
      case ThirdPartyType.supplier:
        return 'Proveedor';
      case ThirdPartyType.organizer:
        return 'Organizador';
      case ThirdPartyType.exhibitor:
        return 'Expositor';
      case ThirdPartyType.customer:
        return 'Cliente';
      case ThirdPartyType.other:
        return 'Otro';
    }
  }

  bool get hasCompleteContactInfo {
    return (contactEmail != null && contactEmail!.isNotEmpty) ||
        (contactPhone != null && contactPhone!.isNotEmpty);
  }

  @override
  String toString() {
    return 'ThirdParty(id: $id, name: $name, type: ${type.name})';
  }
}

enum ThirdPartyType {
  supplier,
  organizer,
  exhibitor,
  customer,
  other,
}
