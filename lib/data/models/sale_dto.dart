import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/domain/entities/sale.dart';

class SaleDTO {
  final String id;
  final String participationId;
  final double amount;
  final String paymentMethod;
  final String products;
  final String? contactId;
  final String? notes;
  final Timestamp createdAt;

  SaleDTO({
    required this.id,
    required this.participationId,
    required this.amount,
    required this.paymentMethod,
    required this.products,
    this.contactId,
    this.notes,
    required this.createdAt,
  });

  /// Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'participationId': participationId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'products': products,
      'contactId': contactId,
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  /// Crear desde Map de Firebase
  factory SaleDTO.fromMap(Map<String, dynamic> map) {
    return SaleDTO(
      id: map['id'] ?? '',
      participationId: map['participationId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'cash',
      products: map['products'] ?? '',
      contactId: map['contactId'],
      notes: map['notes'],
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  /// Convertir a Entity de dominio
  Sale toEntity() {
    return Sale(
      id: id,
      participationId: participationId,
      amount: amount,
      paymentMethod: _parsePaymentMethod(paymentMethod),
      products: products,
      contactId: contactId,
      notes: notes,
      createdAt: createdAt.toDate(),
    );
  }

  /// Crear desde Entity de dominio
  factory SaleDTO.fromEntity(Sale entity) {
    return SaleDTO(
      id: entity.id,
      participationId: entity.participationId,
      amount: entity.amount,
      paymentMethod: _paymentMethodToString(entity.paymentMethod),
      products: entity.products,
      contactId: entity.contactId,
      notes: entity.notes,
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }

  static PaymentMethod _parsePaymentMethod(String method) {
    switch (method) {
      case 'cash':
        return PaymentMethod.cash;
      case 'credit card':
      case 'creditCard':
        return PaymentMethod.creditCard;
      case 'debit card':
      case 'debitCard':
        return PaymentMethod.debitCard;
      case 'transfer':
        return PaymentMethod.transfer;
      case 'other':
        return PaymentMethod.other;
      default:
        throw Exception('Unknown payment method: $method');
    }
  }

  static String _paymentMethodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.creditCard:
        return 'credit_card';
      case PaymentMethod.debitCard:
        return 'debit_card';
      case PaymentMethod.transfer:
        return 'transfer';
      case PaymentMethod.other:
        return 'other';
    }
  }
}
