// lib/repositories/participation_repository.dart

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

  /// Guarda o actualiza una participación.
  /// 
  /// Si la participación es nueva (id vacío), la crea.
  /// Si ya existe, la actualiza.
  Future<Result<Participation>> saveParticipation(
      Participation participation) async {
    if (participation.isNew) {
      // Crear nueva participación
      return await add(participation);
    } else {
      // Actualizar existente
      final updateResult = await update(participation.id, participation);
      return updateResult.isSuccess
          ? Result.success(participation)
          : Result.error(updateResult.error!);
    }
  }

  /// Obtiene todas las participaciones de un usuario.
  Future<Result<List<Participation>>> getParticipationsByUserId(
      String userId) async {
    try {
      final raw = await firestoreService.getDocumentsWhere(
        collectionPath,
        'userId',
        userId,
      );
      final items = raw.map((m) => fromMap(m)).toList();
      return Result.success(items);
    } catch (e) {
      return Result.error('Error al obtener participaciones: $e');
    }
  }

  /// Stream de participaciones de un usuario.
  Stream<List<Participation>> streamParticipationsByUserId(String userId) {
    return firestoreService
        .streamCollectionWhere(collectionPath, 'userId', userId)
        .map((list) => list.map((m) => fromMap(m)).toList());
  }

  // ===== MÉTODOS PARA SUB-COLECCIONES =====

  /// Agrega un contacto a una participación.
  Future<Result<Contact>> addContact(
      String participationId, Contact contact) async {
    try {
      // Crear nuevo contacto con participationId asignado
      final contactData = {
        'participationId': participationId,
        'thirdPartyId': contact.thirdPartyId,
        'notes': contact.notes,
        'createdAt': contact.createdAt,
      };
      
      final id = await firestoreService.addDocument(
        '$collectionPath/$participationId/contacts',
        contactData,
      );
      
      if (id == null) {
        return Result.error('No se pudo crear el contacto');
      }
      
      // Retornar el contacto completo con ID asignado
      final newContact = Contact(
        id: id,
        participationId: participationId,
        thirdPartyId: contact.thirdPartyId,
        notes: contact.notes,
        createdAt: contact.createdAt,
      );
      
      return Result.success(newContact);
    } catch (e) {
      return Result.error('Error al agregar contacto: $e');
    }
  }

  /// Stream de contactos de una participación.
  Stream<List<Contact>> streamContacts(String participationId) {
    return firestoreService
        .streamCollection('$collectionPath/$participationId/contacts')
        .map((list) => list.map((m) => Contact.fromMap(m)).toList());
  }

  /// Agrega una venta a una participación.
  Future<Result<Sale>> addSale(String participationId, Sale sale) async {
    try {
      final saleWithParticipation =
          sale.copyWith(participationId: participationId);
      final id = await firestoreService.addDocument(
        '$collectionPath/$participationId/sales',
        saleWithParticipation.toMap(),
      );
      if (id == null) {
        return Result.error('No se pudo crear la venta');
      }
      return Result.success(saleWithParticipation.copyWith(id: id));
    } catch (e) {
      return Result.error('Error al agregar venta: $e');
    }
  }

  /// Stream de ventas de una participación.
  Stream<List<Sale>> streamSales(String participationId) {
    return firestoreService
        .streamCollection('$collectionPath/$participationId/sales')
        .map((list) => list.map((m) => Sale.fromMap(m)).toList());
  }

  /// Agrega un registro de visitantes a una participación.
  Future<Result<Visitor>> addVisitor(
      String participationId, Visitor visitor) async {
    try {
      final visitorWithParticipation =
          visitor.copyWith(participationId: participationId);
      final id = await firestoreService.addDocument(
        '$collectionPath/$participationId/visitors',
        visitorWithParticipation.toMap(),
      );
      if (id == null) {
        return Result.error('No se pudo crear el registro de visitantes');
      }
      return Result.success(visitorWithParticipation.copyWith(id: id));
    } catch (e) {
      return Result.error('Error al agregar visitantes: $e');
    }
  }

  /// Stream de visitantes de una participación.
  Stream<List<Visitor>> streamVisitors(String participationId) {
    return firestoreService
        .streamCollection('$collectionPath/$participationId/visitors')
        .map((list) => list.map((m) => Visitor.fromMap(m)).toList());
  }

  /// Agrega una participación (método legacy para compatibilidad).
  @Deprecated('Use add() directly from BaseRepository')
  Future<Result<Participation>> addParticipation(
      Participation participation) async {
    return await add(participation);
  }
}
