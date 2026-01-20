import 'package:guia_start/domain/entities/entity.dart';

class Sale extends Entity {
  @override
  final String id;
  final String participationId;
  final double amount;
  final PaymentMethod paymentMethod;
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
    required this.createdAt,
  });

  @override
  Sale copyWith({
    String? id,
    String? participationId,
    double? amount,
    PaymentMethod? paymentMethod,
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

  bool get hasContact => contactId != null && contactId!.isNotEmpty;
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  @override
  String toString() {
    return 'Sale(id: $id, amount: \\$amount, method: ${paymentMethod.name})';
  }
}

enum PaymentMethod {
  cash,
  creditCard,
  debitCard,
  transfer,
  other;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.creditCard:
        return 'Tarjeta de Crédito';
      case PaymentMethod.debitCard:
        return 'Tarjeta Débito';
      case PaymentMethod.transfer:
        return 'Transferencia';
      case PaymentMethod.other:
        return 'Otro';
    }
  }
}
