import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/utils/entity.dart';

enum ThirdPartyType {
  supplier,
  organizer,
  exhibitor,
  customer,
  other,
}

class ThirdParty {
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
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.toString().split('.').last,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'address': address,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ThirdParty.fromMap(Map<String, dynamic> map) {
    return ThirdParty(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: ThirdPartyType.values.firstWhere(
          (e) => e.toString().split('.').last == map['type'],
          orElse: () => ThirdPartyType.other),
      contactEmail: map['contactEmail'],
      contactPhone: map['contactPhone'],
      address: map['address'],
      notes: map['notes'],
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

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

  // Retorna una presentación legible del tercero
  @override
  String toString() {
    return 'ThirdParty{id: $id, name: $name, type: ${type.toString().split('.').last})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThirdParty && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

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

  bool get hashCompleteContact {
    return contactEmail != null || contactPhone != null;
  }
}
