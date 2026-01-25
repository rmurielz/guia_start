import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/edition.dart';

/// Contrato para operaciones de Edition
abstract class EditionRepository {
  /// Crea una nueva edición
  Future<Result<Edition>> create(Edition edition);

  ///Obtiene una edición por ID
  Future<Result<Edition>> getById(String id);

  ///Obtiene todas las ediciones
  Future<Result<List<Edition>>> getAll();

  /// Obtiene ediciones de una feria específica
  Future<Result<List<Edition>>> getByFairId(String fairId);

  /// Obtiene ediciones Activas
  Future<Result<List<Edition>>> getActive();

  /// Actualiza una edición
  Future<Result<Edition>> update(Edition edition);

  /// Elimina una edición
  Future<Result<void>> delete(String id);

  /// Stream de ediciones por feria
  Stream<List<Edition>> watchByFairId(String fairId);

  /// Stream de una edición específica
  Stream<Edition?> watchById(String id);
}
