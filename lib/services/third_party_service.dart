import 'package:guia_start/models/third_party_model.dart';
import 'package:guia_start/repositories/third_party_repository.dart';
import 'package:guia_start/utils/result.dart';

class CreateThirdPartyRequest {
  final String name;
  final ThirdPartyType type;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final String? notes;
  final String createdBy;

  CreateThirdPartyRequest({
    required this.name,
    required this.type,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.notes,
    required this.createdBy,
  });
}

/// Service que maneja la lógica de negocio de terceros.
///
/// Rsponsabilidades:
/// - Validar datos de contacto.
/// - Validar duplicados por nombre.
/// - Búsqueda y filtrado.

class ThirdPartyService {
  final ThirdPartyRepository _thirdPartyRepo = ThirdPartyRepository();

  /// Crea un nuevo tercero después de validar los datos.
  ///
  /// Valida:
  /// Formato de email (si se proporciona).
  /// Formato de teléfono (si se proporciona).
  /// Que no exista otro tercero con el mismo nombre.

  Future<Result<ThirdParty>> createThirdParty(
      CreateThirdPartyRequest request) async {
    // Validar email
    if (request.contactEmail != null &&
        request.contactEmail!.isNotEmpty &&
        !_isValidEmail(request.contactEmail!)) {
      return Result.error('Formato de email inválido.');
    }

    // Validar duplicados por nombre
    final isDuplicate = await _isDuplicateThirdParty(request.name);
    if (isDuplicate) {
      return Result.error('Ya existe un tercero con ese nombre.');
    }

    // Crear el tercero
    final thirdParty = ThirdParty(
      id: '', // Será asignado por el repositorio
      name: request.name.trim(),
      type: request.type,
      contactEmail: request.contactEmail?.trim(),
      contactPhone: request.contactPhone?.trim(),
      address: request.address?.trim(),
      notes: request.notes?.trim(),
      createdBy: request.createdBy,
      createdAt: DateTime.now(),
    );

    final result = await _thirdPartyRepo.add(thirdParty);
    if (result.isError) {
      return Result.error('Error al crear el tercero: ${result.error}');
    }
    return Result.success(result.data!);
  }

  /// Obtiene un tercero por su ID.
  Future<Result<ThirdParty>> getThirdPartyById(String id) async {
    return await _thirdPartyRepo.getById(id);
  }

  /// Obtiene todos los terceros
  Future<Result<List<ThirdParty>>> getAllThirdParties() async {
    return await _thirdPartyRepo.getAll();
  }

  /// Obtiene terceros por tipo
  Future<Result<List<ThirdParty>>> getThirdPartiesByType(
      ThirdPartyType type) async {
    try {
      final thirdParties = await _thirdPartyRepo.getThirdPartiesById(type);

      return Result.success(thirdParties);
    } catch (e) {
      return Result.error('Error al obtener terceros por tipo: $e');
    }
  }

  /// Busca terceros por nombre
  Future<Result<List<ThirdParty>>> searchThirdPartiesByName(
      String query) async {
    try {
      final thirdParties =
          await _thirdPartyRepo.searchThirdPartiesByName(query);
      return Result.success(thirdParties);
    } catch (e) {
      return Result.error('Error al buscar terceros por nombre: $e');
    }
  }

  /// Busca organizadores específicamente
  Future<Result<List<ThirdParty>>> searchOrganizers(String query) async {
    try {
      final results = await _thirdPartyRepo.searchThirdPartiesByName(query);
      final organizers =
          results.where((tp) => tp.type == ThirdPartyType.organizer).toList();
      return Result.success(organizers);
    } catch (e) {
      return Result.error('Error al buscar organizadores: $e');
    }
  }

  /// Actualiza un tercero existente.
  ///
  /// Valida las mismas reglas que al crear.
  Future<Result<ThirdParty>> updateThirdParty(
      ThirdParty updatedThirdParty) async {
//1.  Validar que exista el tercero
    final existingResult = await _thirdPartyRepo.getById(updatedThirdParty.id);
    if (existingResult.isError) {
      return Result.error('Tercero no encontrado.');
    }
    final existing = existingResult.data!;

    //2. Validar email
    if (updatedThirdParty.contactEmail != null &&
        updatedThirdParty.contactEmail!.isNotEmpty &&
        !_isValidEmail(updatedThirdParty.contactEmail!)) {
      return Result.error('Formato de email inválido.');
    }
    //3. Validar duplicados por nombre (si el nombre cambió)
    if (updatedThirdParty.name != existing.name) {
      final isDuplicate = await _isDuplicateThirdParty(updatedThirdParty.name,
          excludeId: updatedThirdParty.id);
      if (isDuplicate) {
        return Result.error('Ya existe un tercero con ese nombre.');
      }
    }
    //4. Actualizar el tercero
    final updateResult =
        await _thirdPartyRepo.update(updatedThirdParty.id, updatedThirdParty);
    if (updateResult.isError) {
      return Result.error(
          'Error al actualizar el tercero: ${updateResult.error}');
    }
    return Result.success(updatedThirdParty);
  }

  /// Elimina un tercero por su ID.
  ///
  /// TODO: Validar que no esté siendo usado como organizador en eventos.
  /// o en otras entidades antes de eliminar.
  Future<Result<bool>> deleteThirdParty(String thirdPartyId) async {
    return await _thirdPartyRepo.delete(thirdPartyId);
  }

  /// Valida si existe un tercero con el mismo nombre.
  Future<bool> _isDuplicateThirdParty(String name, {String? excludeId}) async {
    final allThirdParties = await _thirdPartyRepo.getAll();
    if (allThirdParties.isError) {
      return false;
    }
    return allThirdParties.data!.any((tp) =>
        tp.name.toLowerCase() == name.toLowerCase() && tp.id != excludeId);
  }

  /// Valida el formato de un email.
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Stream de terceros por tipo
  Stream<List<ThirdParty>> streamThirdPartiesByType(ThirdPartyType type) {
    return _thirdPartyRepo.streamThirdPartiesByType(type);
  }

  /// Obtiene estadísticas de terceros por tipo
  Future<Result<Map<ThirdPartyType, int>>> getThirdPartyStats() async {
    final allResult = await _thirdPartyRepo.getAll();
    if (allResult.isError) {
      return Result.error('Error al obtener estadísticas');
    }

    final stats = <ThirdPartyType, int>{};
    for (var type in ThirdPartyType.values) {
      stats[type] = allResult.data!.where((tp) => tp.type == type).length;
    }
    return Result.success(stats);
  }

  /// Valida si un tercero tiene información de contacto completa.
  bool hasCompleteContactInfo(ThirdParty thirdParty) {
    return thirdParty.contactEmail != null &&
            thirdParty.contactEmail!.isNotEmpty ||
        thirdParty.contactPhone != null && thirdParty.contactPhone!.isNotEmpty;
  }
}
