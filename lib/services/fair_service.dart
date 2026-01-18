import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/models/third_party_model.dart';
import 'package:guia_start/repositories/fair_repository.dart';
import 'package:guia_start/repositories/third_party_repository.dart';
import 'package:guia_start/utils/result.dart';

/// DTO (Data Transfer Object) para crear una feria

class CreateFairRequest {
  final String name;
  final String description;
  final String organizerId;
  final bool isRecurring;
  final String createdBy;

  CreateFairRequest({
    required this.name,
    required this.description,
    required this.organizerId,
    required this.isRecurring,
    required this.createdBy,
  });
}

/// DTO que incluye los datos de feria y organizador

class FairWithOrganizer {
  final Fair fair;
  final ThirdParty organizer;

  FairWithOrganizer({
    required this.fair,
    required this.organizer,
  });
}

/// Service que maneja la lógica de negocio relacionada con ferias
///
/// Responsabilidades:
/// - Validaciones de negocio
/// - Operaciones que involucran múltiples repositorios
/// - Transformaciones de datos

class FairService {
  final FairRepository _fairRepo = FairRepository();
  final ThirdPartyRepository _thirdPartyRepo = ThirdPartyRepository();

  /// Crea una nueva feria con validaciones de negocio
  ///
  /// Valida
  /// - Que el organizador exista
  /// - Que el organizador sea tipo 'organizer'
  /// - Que no exista otra feria con el mismo nombre para el mismo organizador

  Future<Result<Fair>> createFair(CreateFairRequest request) async {
    // Validar que el organizador exista
    final organizerResult = await _thirdPartyRepo.getById(request.organizerId);
    if (organizerResult.isError) {
      return Result.error('Organizador no encontrado');
    }
    final organizer = organizerResult.data!;

    // Validar que el organizador sea tipo 'organizer'
    if (organizer.type != ThirdPartyType.organizer) {
      return Result.error('El tercero no es un organizador válido');
    }

    // Validar que no exista otra feria con el mismo nombre para el mismo organizador
    final isDuplicate = await _isDuplicateFair(
      request.name,
      request.organizerId,
    );
    if (isDuplicate) {
      return Result.error(
          'Ya existe una feria con ese nombre para este organizador');
    }

    // Crear la feria
    final fair = Fair(
      id: '', // El ID será asignado por el repositorio
      name: request.name.trim(),
      description: request.description.trim(),
      organizerId: request.organizerId,
      isRecurring: request.isRecurring,
      createdBy: request.createdBy,
      createdAt: DateTime.now(),
    );

    final result = await _fairRepo.add(fair);
    if (result.isError) {
      return Result.error('Error al crear la feria: ${result.error}');
    }
    return Result.success(result.data!);
  }

  /// Obtiene una feria junto con los datos del organizador

  Future<Result<FairWithOrganizer>> getFairWithOrganizer(String fairId) async {
    final fairResult = await _fairRepo.getById(fairId);
    if (fairResult.isError) {
      return Result.error('Feria no encontrada');
    }
    final fair = fairResult.data!;
    final organizerResult = await _thirdPartyRepo.getById(fair.organizerId);

    if (organizerResult.isError) {
      return Result.error('Organizador no encontrado');
    }
    return Result.success(
      FairWithOrganizer(
        fair: fair,
        organizer: organizerResult.data!,
      ),
    );
  }

  /// Busca ferias por nombre
  ///
  Future<Result<List<Fair>>> searchFairs(String query) async {
    try {
      final fairs = await _fairRepo.searchFairByName(query);
      return Result.success(fairs);
    } catch (e) {
      return Result.error('Error al buscar ferias: $e');
    }
  }

  /// Obtiene todas las ferias
  Future<Result<List<Fair>>> getAllFairs() async {
    return await _fairRepo.getAll();
  }

//// Obtiene una feria por ID
  Future<Result<Fair>> getFairById(String id) async {
    return await _fairRepo.getById(id);
  }

  /// Actualiza una feria existente
  ///
  /// Valida:
  /// - Que la feria exista
  /// - Que el nuevo organizador exista (si se cambia)
  /// - Que no hay aduplicados (si se cambia el nombre o el organizador)

  Future<Result<Fair>> updateFair(Fair updatedFair) async {
    final existingResult = await _fairRepo.getById(updatedFair.id);
    if (existingResult.isError) {
      return Result.error('Feria no encontrada');
    }

    final existing = existingResult.data!;

    if (updatedFair.organizerId != existing.organizerId) {
      final organizerResult =
          await _thirdPartyRepo.getById(updatedFair.organizerId);
      if (organizerResult.isError) {
        return Result.error('Organizador no encontrado');
      }
      final organizer = organizerResult.data!;
      if (organizer.type != ThirdPartyType.organizer) {
        return Result.error('El tercero no es un organizador válido');
      }
    }
    if (updatedFair.name != existing.name) {
      final isDuplicate = await _isDuplicateFair(
        updatedFair.name,
        updatedFair.organizerId,
        excludeFairId: updatedFair.id,
      );
      if (isDuplicate) {
        return Result.error(
            'Ya existe una feria con ese nombre para este organizador');
      }
    }
    final updateResult = await _fairRepo.update(updatedFair.id, updatedFair);
    if (updateResult.isError) {
      return Result.error(
          'Error al actualizar la feria: ${updateResult.error}');
    }
    return Result.success(updatedFair);
  }

  /// Elimina una feria
  ///
  /// TODO: En el futuro, validar que no tenga ediciones asociadas
  /// o implementar eliminación en cascada.

  Future<Result<bool>> deleteFair(String fairId) async {
    return await _fairRepo.delete(fairId);
  }

  /// Valida si existe una feria duplicada por nombre y organizador
  ///

  /// Si se proporciona [excludeFairId], se excluye esa feria de la validación
  Future<bool> _isDuplicateFair(
    String name,
    String organizerId, {
    String? excludeFairId,
  }) async {
    final allFairs = await _fairRepo.getAll();
    if (allFairs.isError) return false;

    return allFairs.data!.any((fair) =>
        fair.name.toLowerCase() == name.toLowerCase() &&
        fair.organizerId == organizerId &&
        fair.id != excludeFairId);
  }

  Future<Result<List<FairWithOrganizer>>> searchFairWithOrganizer(
      String query) async {
    try {
      final fairs = await _fairRepo.searchFairByName(query);
      List<FairWithOrganizer> detailResults = [];

      for (var fair in fairs) {
        final orgResult = await _thirdPartyRepo.getById(fair.organizerId);
        if (orgResult.isSuccess) {
          detailResults.add(FairWithOrganizer(
            fair: fair,
            organizer: orgResult.data!,
          ));
        }
      }
      return Result.success(detailResults);
    } catch (e) {
      return Result.error('Error al buscar ferias: $e');
    }
  }
}
