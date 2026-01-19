import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/utils/entity.dart';

class Sale extends Entity {
  @override
  final String id;
  final String participationId;
  final double amount;
  final String paymentMethod;
  final String products;
  final String? contactId;
  final String? notes;
  final DateTime createdAt;

  Sale({
    required this.id,
    required this.participationId,
    required this.amount,
    required this.paymentMethod,
    required this.products,
    this.contactId,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'participationId': participationId,
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
      participationId: map['participationId'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? 'cash',
      products: map['products'] ?? '',
      contactId: map['contactId'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  Sale copyWith({
    String? id,
    String? participationId,
    double? amount,
    String? paymentMethod,
    String? products,
    String? contactId,
    String? notes,
    DateTime? createdAt,
  }) {
    return Sale(
      id: id ?? this.id,
      participationId: participationId ?? this.participationId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      products: products ?? this.products,
      contactId: contactId ?? this.contactId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Sale(id: $id, amount: \$$amount, method: $paymentMethod, participation: $participationId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sale && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
  bool get hasContact => contactId != null && contactId!.isNotEmpty;
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'cash':
        return 'Efectivo';
      case 'credit_card':
        return 'Tarejeta de Crédito';
      case 'debit_card':
        return 'tarjeta de Débito';
      case 'transfer':
        return 'Transferencia';
      default:
        return paymentMethod;
    }
  }
}
