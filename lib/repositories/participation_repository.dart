import 'package:guia_start/models/participation_model.dart';
import 'package:guia_start/models/contact_model.dart';
import 'package:guia_start/models/sale_model.dart';
import 'package:guia_start/models/visitor_model.dart';
import 'package:guia_start/repositories/base_repository.dart';
import 'package:guia_start/utils/result.dart';

class ParticipationRepository extends BaseRepository<Participation> {
  @override
  String get collectionPath => 'participations';

  @override
  Participation Function(Map<String, dynamic>) get fromMap =>
      Participation.fromMap;

  @override
  Map<String, dynamic> Function(Participation) get toMap => (p) => p.toMap();

  Future<Result<Participation>> saveParticipation(
      Participation participation) async {
    if (participation.isNew) {
      return await add(participation);
    } else {
      final updateResult = await update(participation.id, participation);
      return updateResult.isSuccess
          ? Result.success(participation)
          : Result.error(updateResult.error!);
    }
  }

  Future<Result<List<Participation>>> getParticipationsByUserId(
      String userId) async {
    try {
      final raw = await firestoreService.getDocumentsWhere(
          collectionPath, 'userId', userId);
      final items = raw.map((m) => fromMap(m)).toList();
      return Result.success(items);
    } catch (e) {
      return Result.error('Error al obtener participaciones $e');
    }
  }

  Stream<List<Participation>> streamParticipationsByUserId(String userId) {
    return firestoreService
        .streamCollectionWhere(collectionPath, 'userId', userId)
        .map((List) => List.map((m) => fromMap(m)).toList());
  }

  // ========== MÉTODOS PARA SUBCOLECCIONES ==========

  /// Agrega un contacto a una participación
  Future<Result<Contact>> addContact(
    String participationId,
    Contact contact,
  ) async {
    try {
      // Crear nuevo contacto con participationId
      final contactWithParticipation = Contact(
        id: contact.id,
        participationId: participationId,
        thirdPartyId: contact.thirdPartyId,
        notes: contact.notes,
        createdAt: contact.createdAt,
      );

      final id = await firestoreService.addDocument(
        '$collectionPath/$participationId/contacts',
        contactWithParticipation.toMap(),
      );

      if (id == null) {
        return Result.error('Error al agregar el contacto');
      }
      return Result.success(
        contactWithParticipation.copyWith(id: id),
      );
    } catch (e) {
      return Result.error('Error al agregar el contacto $e');
    }
  }

  /// Agrega una venta a una participación
  Future<Result<Sale>> addSale(String participationId, Sale sale) async {
    try {
      final saleWithParticipation = Sale(
        id: sale.id,
        participationId: participationId,
        amount: sale.amount,
        paymentMethod: sale.paymentMethod,
        products: sale.products,
        contactId: sale.contactId,
        notes: sale.notes,
        createdAt: sale.createdAt,
      );

      final id = await firestoreService.addDocument(
        '$collectionPath/$participationId/sales',
        saleWithParticipation.toMap(),
      );

      if (id == null) {
        return Result.error('Error al agregar la venta');
      }
      return Result.success(
        saleWithParticipation.copyWith(id: id),
      );
    } catch (e) {
      return Result.error('Error al agregar la venta $e');
    }
  }

  //// Stream de ventas de una participación
  Stream<List<Sale>> streamSales(String participationId) {
    return firestoreService
        .streamCollection(
          '$collectionPath/$participationId/sales',
        )
        .map((List) => List.map((m) => Sale.fromMap(m)).toList());
  }

  /// Agrega un registro de visitante a una participación
  Future<Result<Visitor>> addVisitor(
    String participationId,
    Visitor visitor,
  ) async {
    try {
      final visitorWithParticipation = Visitor(
        id: visitor.id,
        participationId: participationId,
        count: visitor.count,
        notes: visitor.notes,
        timestamp: visitor.timestamp,
      );

      final id = await firestoreService.addDocument(
        '$collectionPath/$participationId/visitors',
        visitorWithParticipation.toMap(),
      );

      if (id == null) {
        return Result.error('Error al agregar el visitante');
      }
      return Result.success(
        visitorWithParticipation.copyWith(id: id),
      );
    } catch (e) {
      return Result.error('Error al agregar el visitante $e');
    }
  }

  /// Stream de visitantes de una participación
  Stream<List<Visitor>> streamVisitors(String participationId) {
    return firestoreService
        .streamCollection(
          '$collectionPath/$participationId/visitors',
        )
        .map((List) => List.map((m) => Visitor.fromMap(m)).toList());
  }

  /// Agrega una participación (método legacy para compatibilidad)
  @Deprecated('Use add ()directly from BaseRepository instead')
  Future<Result<Participation>> createParticipation(
      Participation participation) async {
    return await add(participation);
  }
}
