import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/repositories/participation_repository.dart';
import 'package:guia_start/domain/repositories/edition_repository.dart';
import 'package:guia_start/domain/entities/edition.dart';

/// UseCase para obtener estadísticas del dashboard
class GetDashboardStatsUseCase implements UseCase<DashboardStats, String> {
  final ParticipationRepository _participationRepository;
  final EditionRepository _editionRepository;

  GetDashboardStatsUseCase({
    required ParticipationRepository participationRepository,
    required EditionRepository editionRepository,
  })  : _participationRepository = participationRepository,
        _editionRepository = editionRepository;

  @override
  Future<Result<DashboardStats>> call(String userId) async {
    try {
      // 1. Obtener todas las participaciones del usuario
      final participationsResult =
          await _participationRepository.getByUserId(userId);

      if (participationsResult.isError) {
        return Result.failure(participationsResult.failure!);
      }

      final participations = participationsResult.data ?? [];

      // 2. Obtener ediciones para determinar estados
      int activeCount = 0;
      int upcomingCount = 0;
      final now = DateTime.now();

      for (final participation in participations) {
        final editionResult =
            await _editionRepository.getById(participation.editionId);

        if (editionResult.isSuccess) {
          final edition = editionResult.data!;

          // Contar según estado
          if (edition.status == EditionStatus.active) {
            activeCount++;
          } else if (edition.status == EditionStatus.planning &&
              edition.initDate.isAfter(now)) {
            upcomingCount++;
          }
        }
      }

      final stats = DashboardStats(
        totalParticipations: participations.length,
        activeParticipations: activeCount,
        upcomingParticipations: upcomingCount,
      );

      return Result.success(stats);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al cargar estadísticas: $e'),
      );
    }
  }
}

/// Estadísticas del dashboard
class DashboardStats {
  final int totalParticipations;
  final int activeParticipations;
  final int upcomingParticipations;

  DashboardStats({
    required this.totalParticipations,
    required this.activeParticipations,
    required this.upcomingParticipations,
  });

  bool get hasParticipations => totalParticipations > 0;
  bool get hasActive => activeParticipations > 0;
  bool get hasUpcoming => upcomingParticipations > 0;
}
