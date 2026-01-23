import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/fair.dart';
import 'package:guia_start/domain/entities/third_party.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';
import 'package:guia_start/domain/repositories/third_party_repository.dart';

class UpdateFairUsecase implements UseCase<Fair, Fair> {
  final FairRepository _fairRepository;
  final ThirdPartyRepository _thirdPartyRepository;

  UpdateFairUsecase({
    required FairRepository fairRepository,
    required ThirdPartyRepository thirdPartyRepository,
  })  : _fairRepository = fairRepository,
        _thirdPartyRepository = thirdPartyRepository;

  @override
  Future<Result<Fair>> call(Fair fair) async {
    // 1.  Verificar que la feria exista
    final existingResult = await _fairRepository.getById(fair.id);

    if (existingResult.isError) {
      return Result.failure(
        const NotFoundFailure('Feria no encontrada'),
      );
    }

    final existing = existingResult.data!;

    // 2.  Si cambió el organizador, validar que exista y sea tipo organizador

    if (fair.organizerId != existing.organizerId) {
      final organizerResult = await _thirdPartyRepository.getById(
        fair.organizerId,
      );

      if (organizerResult.isError) {
        return Result.failure(
          const NotFoundFailure('Organizador no encontrado'),
        );
      }

      if (organizerResult.data!.type != ThirdPartyType.organizer) {
        return Result.failure(
          const ValidationFailure('El tercero no es un organizador válido'),
        );
      }
    }

    // 3.  Si cambió el nombre, validar duplicados
    if (fair.name.toLowerCase() != existing.name.toLowerCase()) {
      final fairsResult = await _fairRepository.getByOrganizer(
        fair.organizerId,
      );

      if (fairsResult.isSuccess) {
        final isDuplicate = fairsResult.data!.any(
          (f) =>
              f.id != fair.id &&
              f.name.toLowerCase() == fair.name.toLowerCase(),
        );

        if (isDuplicate) {
          return Result.failure(
            const ValidationFailure(
              'Ya existe una feria con ese nombre para este organizador',
            ),
          );
        }
      }
    }
    return await _fairRepository.update(fair);
  }
}
