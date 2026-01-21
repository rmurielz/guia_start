import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/fair.dart';

/// Contrato de operaciones de Fair
abstract class FairRepository {
  /// Crea una feria
  Future<Result<Fair>> create(Fair fair);

  /// Obtiene una feria por ID
  Future<Result<Fair>> getById(String id);

  /// Obtiene todas las ferias
  Future<Result<List<Fair>>> getAll();

  /// Busca ferias por nombre
  Future<Result<List<Fair>>> searchByName(String query);

  ///Obtiene ferias de un organizador específico
  Future<Result<List<Fair>>> getByOrganizer(String organizerId);

  /// Actualiza una feria existente
  Future<Result<Fair>> update(Fair fair);

  ///Elimina una feria
  Future<Result<void>> delete(String id);

  /// Stream de todas las ferias
  Stream<List<Fair>> watchAll();

  /// Stream de una feria específica
  Stream<Fair?> watchById(String id);
}
