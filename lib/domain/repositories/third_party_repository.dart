import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/third_party.dart';

/// Contrato para operaciones de ThirdParty
abstract class ThirdPartyRepository {
  /// Crea un nuevo tercero
  Future<Result<ThirdParty>> create(ThirdParty thirdParty);

  /// Obtiene un tercero por ID
  Future<Result<ThirdParty>> getById(String id);

  /// Obtiene todos los terceros
  Future<Result<List<ThirdParty>>> getAll();

  /// Busca proveedores por nombre
  Future<Result<List<ThirdParty>>> searchByName(String query);

  /// Obtiene terceros por tipo
  Future<Result<List<ThirdParty>>> getByType(String type);

  /// Actualiza un proveedor
  Future<Result<ThirdParty>> update(ThirdParty thirdParty);

  /// Elimina un proveedor
  Future<Result<void>> delete(String id);

  /// Stream de todos los terceros por tipo
  Stream<List<ThirdParty>> watchByType(ThirdPartyType type);

  /// Stream de un tercero específico
  Stream<ThirdParty?> watchById(String id);
}
