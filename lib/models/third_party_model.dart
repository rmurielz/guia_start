import 'package:cloud_firestore/cloud_firestore.dart';

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
}
