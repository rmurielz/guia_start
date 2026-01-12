import 'package:guia_start/models/edition_model.dart';
import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/repositories/edition_repository.dart';
import 'package:guia_start/repositories/fair_repository.dart';
import 'package:guia_start/utils/result.dart';

/// DTO para crear una edición.

class CreateEditionRequest {
  final String fairId;
  final String name;
  final String location;
  final DateTime initDate;
  final DateTime endDate;
  final String createdBy;
  final String? status;

  CreateEditionRequest({
    required this.fairId,
    required this.name,
    required this.location,
    required this.initDate,
    required this.endDate,
    required this.createdBy,
    required this.status,
  });
}

/// DTO que incluye edición con datos de la feria
class EditionWithFair {
  final Edition edition;
  final Fair fair;

  EditionWithFair({
    required this.edition,
    required this.fair,
  });
}

/// Servicio que maneja la lógica de negocio de ediciones
///
/// Rsponsabilidades:
/// - Validar que las fechas sean coherentes
/// - Validar que la feria exista
/// - Validar que no haya ediciones superpuestas (opcional)
/// - Obtener ediciones con datos de la feria
class EditionService {
  final EditionRepository _editionRepo = EditionRepository();
  final FairRepository _fairRepo = FairRepository();

  /// Crea una nueva edición con validaciones
  ///
  /// Valida:
  /// - Que la feria exista
  /// - Que las fechas sean coherentes
  /// - Que no haya ediciones superpuestas
  Future<Result<Edition>> createEdition(CreateEditionRequest request) async {
    // Validar que la feria exista
    final fairResult = await _fairRepo.getById(request.fairId);
    if (fairResult.isError) {
      return Result.error('La feria seleccionada no existe.');
    }

    // Validar que las fechas sean coherentes
    if (request.endDate.isBefore(request.initDate)) {
      return Result.error(
          'La fecha de fin no puede ser anterior a la fecha de inicio.');
    }

    /// if (request.endDate.isAtSameMomentAs(request.initDate)) {
    /// return Result.error('La fecha de fin no puede ser igual a la fecha de inicio.');
    /// }

// Validar que no haya ediciones superpuestas (opcional)
    final hasOverlap = await _hasDateOverlap(
      request.fairId,
      request.initDate,
      request.endDate,
    );

    if (hasOverlap) {
      return Result.error('Ya existe una edición en las fechas seleccionadas.');
    }

    //4 Crear la edición
    final edition = Edition(
        id: '',
        fairId: request.fairId,
        name: request.name.trim(),
        location: request.location.trim(),
        initDate: request.initDate,
        endDate: request.endDate,
        createdBy: request.createdBy,
        createdAt: DateTime.now(),
        status: request.status ?? 'planning');
    final result = await _editionRepo.add(edition);

    if (result.isError) {
      return Result.error('Error al crear la edición: ${result.error}');
    }
    return Result.success(result.data!);
  }

  /// Obtiene una edición junto con los datos de la feria asociada
  Future<Result<EditionWithFair>> getEditionWithFair(String editionId) async {
    final editionResult = await _editionRepo.getById(editionId);
    if (editionResult.isError) {
      return Result.error('Edición no encontrada.');
    }

    final edition = editionResult.data!;
    final fairResult = await _fairRepo.getById(edition.fairId);

    if (fairResult.isError) {
      return Result.error('Feria asociada no encontrada.');
    }
    return Result.success(
      EditionWithFair(
        edition: edition,
        fair: fairResult.data!,
      ),
    );
  }

  /// Obtiene todas las ediciones de una feria
  Future<Result<List<Edition>>> getEditionsByFairId(String fairId) async {
    try {
      final editions = await _editionRepo.getEditionsByFairId(fairId);
      return Result.success(editions);
    } catch (e) {
      return Result.error('Error al obtener las ediciones: $e');
    }
  }

  /// Obtiene una edición por su ID
  Future<Result<Edition>> getEditionById(String id) async {
    return await _editionRepo.getById(id);
  }

  /// Actualiza una edición existente
  ///
  /// Valida las mismas reglas que al crear
  Future<Result<Edition>> updateEdition(Edition updatedEdition) async {
// 1. Validar que la feria exista
    final existingResult = await _editionRepo.getById(updatedEdition.id);
    if (existingResult.isError) {
      return Result.error('La edición no existe.');
    }
    // 2. Validar que las fechas sean coherentes
    if (updatedEdition.endDate.isBefore(updatedEdition.initDate)) {
      return Result.error(
          'La fecha de fin no puede ser anterior a la fecha de inicio.');
    }

    // 3. Validar que no haya ediciones superpuestas (excluyendo esta edición)
    final hasOverlap = await _hasDateOverlap(
      updatedEdition.fairId,
      updatedEdition.initDate,
      updatedEdition.endDate,
      excludeEditionId: updatedEdition.id,
    );

    if (hasOverlap) {
      return Result.error('Ya existe una edición en las fechas seleccionadas.');
    }

    // 4. Actualizar
    final updateResult =
        await _editionRepo.update(updatedEdition.id, updatedEdition);
    if (updateResult.isError) {
      return Result.error(
          'Error al actualizar la edición: ${updateResult.error}');
    }
    return Result.success(updatedEdition);
  }

  /// Elimina una edición
  ///
  /// TODO: Validar que no tenga dependencias (eventos, expositores, etc.)
  Future<Result<bool>> deleteEdition(String editionId) async {
    return await _editionRepo.delete(editionId);
  }

  /// Cambia el estado de una edición
  ///
  /// Estados válidos: planning, active, finished, cancelled
  Future<Result<Edition>> changeStatus(
      String editionId, String newStatus) async {
    final validStatues = ['planning', 'active', 'finished', 'cancelled'];
    if (!validStatues.contains(newStatus)) {
      return Result.error('Estado inválido: $newStatus');
    }

    final editionResult = await _editionRepo.getById(editionId);
    if (editionResult.isError) {
      return Result.error('Edición no encontrada.');
    }
    final edition = editionResult.data!;
    final updatedEdition = edition.copyWith(status: newStatus);

    final updateResult = await _editionRepo.update(editionId, updatedEdition);
    if (updateResult.isError) {
      return Result.error('Error al cambiar el estado: ${updateResult.error}');
    }
    return Result.success(updatedEdition);
  }

  /// Verifica si hay ediciones superpuestas en las fechas dadas
  Future<bool> _hasDateOverlap(
    String fairId,
    DateTime initDate,
    DateTime endDate, {
    String? excludeEditionId,
  }) async {
    final editions = await _editionRepo.getEditionsByFairId(fairId);

    return editions.any((edition) {
      if (edition.id == excludeEditionId) {
        return false;
      }
      final startsInRange = initDate.isAfter(edition.initDate) &&
          initDate.isBefore(edition.endDate);
      final endsInRange = endDate.isAfter(edition.initDate) &&
          endDate.isBefore(edition.endDate);
      final engulfsOther = initDate.isBefore(edition.initDate) &&
          endDate.isAfter(edition.endDate);
      return startsInRange || endsInRange || engulfsOther;
    });
  }

  /// Stream de ediciones para una feria dada
  Stream<List<Edition>> streamEditionsByFairId(String fairId) {
    return _editionRepo.streamEditionsByFairId(fairId);
  }
}
