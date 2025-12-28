import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String id;
  final double amount;
  final String paymentMethod;
  final String products;
  final String? contactId;
  final String? notes;
  final DateTime createdAt;

  Sale({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.products,
    this.contactId,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'paymentMethod': paymentMethod,
      'products': products,
      'contactId': contactId,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? 'cash',
      products: map['products'] ?? '',
      contactId: map['contactId'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Sale copyWith({
    String? id,
    double? amount,
    String? paymentMethod,
    String? products,
    String? contactId,
    String? notes,
    DateTime? createdAt,
  }) {
    return Sale(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      products: products ?? this.products,
      contactId: contactId ?? this.contactId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
