import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/participation.dart';
import 'package:guia_start/domain/entities/contact.dart';
import 'package:guia_start/domain/entities/sale.dart';
import 'package:guia_start/domain/entities/visitor.dart';

/// Contrato para operaciones de participación
abstract class ParticipationRepository {
  // ======= PARTICIPACIONES =======

  /// Crea una nueva participación
  Future<Result<Participation>> create(Participation participation);

  /// Obtiene una participación por ID
  Future<Result<Participation>> getById(String id);

  /// Obtiene todas las participaciones
  Future<Result<List<Participation>>> getAll();

  /// Obtiene participaciones de un usuario
  Future<Result<List<Participation>>> getByUserId(String userId);

  /// Obtiene participaciones de una edición
  Future<Result<List<Participation>>> getByEditionId(String editionId);

  /// Actualiza una participación
  Future<Result<Participation>> update(Participation participation);

  ///Elimina una participación
  Future<Result<void>> delete(String id);

  /// Stream de participaciones de un usuario
  Stream<List<Participation>> watchByUserId(String userId);

  // ======= Contactos (subcoleection) =======

  /// Agrega un contacto a una participación
  Future<Result<Contact>> addContact(String participationId, Contact contact);

  /// Obtiene contactos de una participación
  Future<Result<List<Contact>>> getContacts(String participationId);

  /// Stream de contactos de una participación
  Stream<List<Contact>> watchContacts(String participationId);

  // ======= Ventas (subcollection) =======

  /// Agrega una venta a una participación
  Future<Result<Sale>> addSale(String participationId, Sale sale);

  /// Obtiene ventas de una participación
  Future<Result<List<Sale>>> getSales(String participationId);

  /// Stream de ventas de una participación
  Stream<List<Sale>> watchSales(String participationId);

// ======= Visitantes (subcollection) =======

  /// Agrega un registro de visitante a una participación
  Future<Result<Visitor>> addVisitor(String participationId, Visitor visitor);

  /// Obtiene visitantes de una participación
  Future<Result<List<Visitor>>> getVisitors(String participationId);

  /// Stream de visitantes de una participación
  Stream<List<Visitor>> watchVisitors(String participationId);
}
