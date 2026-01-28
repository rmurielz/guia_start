import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/edition.dart';
import 'package:guia_start/domain/repositories/edition_repository.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';

/// Caso de uso para crear una nueva edición
/// Valida que:
/// - La feria exista
/// - Las fechas sean coherentes
/// - No se superpongan con otras ediciones de la misma feria
class CreateEditionUseCase implements UseCase<Edition, CreateEditionParams> {
  final EditionRepository editionRepository;
  final FairRepository fairRepository;

  CreateEditionUseCase({
    required this.editionRepository,
    required this.fairRepository,
  });

  @override
  Future<Result<Edition>> call(CreateEditionParams params) async {
    // 1. Validar que la edición tenga fechas válidas
    if (!params.edition.hasValidDates()) {
      return Result.failure(
        ValidationFailure(
            'La fecha de fin debe ser posterior a la fecha de inicio'),
      );
    }

    // 2. Verificar que la feria exista
    final fairResult = await fairRepository.getById(params.edition.fairId);
    if (fairResult.isError) {
      return Result.failure(
        ValidationFailure('La feria especificada no existe'),
      );
    }

    // 3. Obtener ediciones existentes de la misma feria
    final existingEditionsResult = await editionRepository.getByFairId(
      params.edition.fairId,
    );

    if (existingEditionsResult.isSuccess) {
      // 4. Verificar que no se superpongan las fechas
      final existingEditions = existingEditionsResult.data!;
      for (final existing in existingEditions) {
        // No validar contra ediciones canceladas
        if (existing.isCancelled) continue;

        if (params.edition.overlaps(existing)) {
          return Result.failure(
            ValidationFailure(
              'Las fechas se superponen con la edición "${existing.name}"',
            ),
          );
        }
      }
    }

    // 5. Crear la edición
    return await editionRepository.create(params.edition);
  }
}

class CreateEditionParams {
  final Edition edition;

  CreateEditionParams({required this.edition});
}
