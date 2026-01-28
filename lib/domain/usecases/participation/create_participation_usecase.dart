import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/participation.dart';
import 'package:guia_start/domain/repositories/edition_repository.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';
import 'package:guia_start/domain/repositories/participation_repository.dart';

/// Caso de uso para crear una nueva participación
/// Valida que:
/// - La feria exista
/// - La edición exista
/// - La edición pertenezca a la feria especificada
/// - El usuario no tenga ya una participación en esta edición
class CreateParticipationUseCase
    implements UseCase<Participation, CreateParticipationParams> {
  final ParticipationRepository participationRepository;
  final EditionRepository editionRepository;
  final FairRepository fairRepository;

  CreateParticipationUseCase({
    required this.participationRepository,
    required this.editionRepository,
    required this.fairRepository,
  });

  @override
  Future<Result<Participation>> call(CreateParticipationParams params) async {
    final participation = params.participation;

    // 1. Verificar que la feria exista
    final fairResult = await fairRepository.getById(participation.fairId);
    if (fairResult.isError) {
      return Result.failure(
        ValidationFailure('La feria especificada no existe'),
      );
    }

    // 2. Verificar que la edición exista
    final editionResult = await editionRepository.getById(
      participation.editionId,
    );
    if (editionResult.isError) {
      return Result.failure(
        ValidationFailure('La edición especificada no existe'),
      );
    }

    final edition = editionResult.data!;

    // 3. Verificar que la edición pertenezca a la feria
    if (edition.fairId != participation.fairId) {
      return Result.failure(
        ValidationFailure('La edición no pertenece a la feria especificada'),
      );
    }

    // 4. Verificar que la edición esté en estado válido para participar
    if (edition.isCancelled) {
      return Result.failure(
        ValidationFailure('No se puede participar en una edición cancelada'),
      );
    }

    if (edition.isFinished) {
      return Result.failure(
        ValidationFailure('No se puede participar en una edición finalizada'),
      );
    }

    // 5. Verificar que el usuario no tenga ya una participación en esta edición
    final userParticipationsResult = await participationRepository.getByUserId(
      participation.userId,
    );

    if (userParticipationsResult.isSuccess) {
      final existingParticipations = userParticipationsResult.data!;
      final hasExistingParticipation = existingParticipations.any(
        (p) => p.editionId == participation.editionId,
      );

      if (hasExistingParticipation) {
        return Result.failure(
          ValidationFailure(
              'Ya tienes una participación registrada en esta edición'),
        );
      }
    }

    // 6. Crear la participación
    return await participationRepository.create(participation);
  }
}

class CreateParticipationParams {
  final Participation participation;

  CreateParticipationParams({required this.participation});
}
