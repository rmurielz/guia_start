import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/domain/repositories/participation_repository.dart';
import 'package:guia_start/domain/repositories/edition_repository.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';
import 'package:guia_start/domain/entities/participation.dart';
import 'package:guia_start/domain/entities/edition.dart';
import 'package:guia_start/domain/entities/fair.dart';

/// UseCase para obtener la feria más relevante para mostrar en el dashboard
class GetActiveFairUseCase implements UseCase<ActiveFairInfo?, String> {
  final ParticipationRepository _participationRepository;
  final EditionRepository _editionRepository;
  final FairRepository _fairRepository;

  GetActiveFairUseCase({
    required ParticipationRepository participationRepository,
    required EditionRepository editionRepository,
    required FairRepository fairRepository,
  })  : _participationRepository = participationRepository,
        _editionRepository = editionRepository,
        _fairRepository = fairRepository;

  @override
  Future<Result<ActiveFairInfo?>> call(String userId) async {
    try {
      // 1. Obtener participaciones del usuario
      final participationsResult =
          await _participationRepository.getByUserId(userId);

      if (participationsResult.isError) {
        return Result.failure(participationsResult.failure!);
      }

      final participations = participationsResult.data ?? [];

      if (participations.isEmpty) {
        return Result.success(null); // Sin participaciones
      }

      final now = DateTime.now();
      ActiveFairInfo? activeInfo;
      ActiveFairInfo? upcomingInfo;

      // 2. Buscar feria activa o próxima
      for (final participation in participations) {
        final editionResult =
            await _editionRepository.getById(participation.editionId);

        if (editionResult.isError) continue;

        final edition = editionResult.data!;
        final fairResult = await _fairRepository.getById(participation.fairId);

        if (fairResult.isError) continue;

        final fair = fairResult.data!;

        // Feria ACTIVA (prioridad 1)
        if (edition.status == EditionStatus.active) {
          final daysRemaining = edition.endDate.difference(now).inDays;
          activeInfo = ActiveFairInfo(
            participation: participation,
            edition: edition,
            fair: fair,
            status: FairDisplayStatus.active,
            daysUntilStart: 0,
            daysRemaining: daysRemaining > 0 ? daysRemaining : 0,
          );
          break; // Encontramos activa, no seguir buscando
        }

        // Feria PRÓXIMA (prioridad 2)
        if (edition.status == EditionStatus.planning &&
            edition.initDate.isAfter(now)) {
          final daysUntilStart = edition.initDate.difference(now).inDays;

          // Guardar solo la más cercana
          if (upcomingInfo == null ||
              daysUntilStart < upcomingInfo.daysUntilStart) {
            upcomingInfo = ActiveFairInfo(
              participation: participation,
              edition: edition,
              fair: fair,
              status: FairDisplayStatus.upcoming,
              daysUntilStart: daysUntilStart,
              daysRemaining: 0,
            );
          }
        }
      }

      // 3. Retornar activa primero, sino próxima, sino null
      return Result.success(activeInfo ?? upcomingInfo);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener feria activa: $e'),
      );
    }
  }
}

/// Información de la feria a mostrar en el dashboard
class ActiveFairInfo {
  final Participation participation;
  final Edition edition;
  final Fair fair;
  final FairDisplayStatus status;
  final int daysUntilStart; // Para ferias próximas
  final int daysRemaining; // Para ferias activas

  ActiveFairInfo({
    required this.participation,
    required this.edition,
    required this.fair,
    required this.status,
    required this.daysUntilStart,
    required this.daysRemaining,
  });

  bool get isActive => status == FairDisplayStatus.active;
  bool get isUpcoming => status == FairDisplayStatus.upcoming;
}

enum FairDisplayStatus {
  active,
  upcoming,
}
