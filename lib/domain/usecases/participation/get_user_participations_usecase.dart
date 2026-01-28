import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/edition.dart';
import 'package:guia_start/domain/entities/fair.dart';
import 'package:guia_start/domain/entities/participation.dart';
import 'package:guia_start/domain/repositories/edition_repository.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';
import 'package:guia_start/domain/repositories/participation_repository.dart';

/// Caso de uso para obtener todas las participaciones de un usuario
/// con información completa de Fair y Edition
class GetUserParticipationsUseCase
    implements
        UseCase<List<ParticipationDetails>, GetUserParticipationsParams> {
  final ParticipationRepository participationRepository;
  final FairRepository fairRepository;
  final EditionRepository editionRepository;

  GetUserParticipationsUseCase({
    required this.participationRepository,
    required this.fairRepository,
    required this.editionRepository,
  });

  @override
  Future<Result<List<ParticipationDetails>>> call(
    GetUserParticipationsParams params,
  ) async {
    // 1. Obtener participaciones del usuario
    final participationsResult = await participationRepository.getByUserId(
      params.userId,
    );

    if (participationsResult.isError) {
      return Result.failure(participationsResult.failure!);
    }

    final participations = participationsResult.data!;
    final List<ParticipationDetails> details = [];

    // 2. Para cada participación, obtener Fair y Edition
    for (final participation in participations) {
      // Obtener Fair
      final fairResult = await fairRepository.getById(participation.fairId);
      if (fairResult.isError) continue; // Skip si no se encuentra

      // Obtener Edition
      final editionResult = await editionRepository.getById(
        participation.editionId,
      );
      if (editionResult.isError) continue; // Skip si no se encuentra

      details.add(
        ParticipationDetails(
          participation: participation,
          fair: fairResult.data!,
          edition: editionResult.data!,
        ),
      );
    }

    // 3. Ordenar por fecha de edición (más reciente primero)
    details.sort((a, b) => b.edition.initDate.compareTo(a.edition.initDate));

    return Result.success(details);
  }
}

class GetUserParticipationsParams {
  final String userId;

  GetUserParticipationsParams({required this.userId});
}

/// Clase que agrupa una participación con su Fair y Edition
class ParticipationDetails {
  final Participation participation;
  final Fair fair;
  final Edition edition;

  ParticipationDetails({
    required this.participation,
    required this.fair,
    required this.edition,
  });

  // Helpers útiles
  String get fairName => fair.name;
  String get editionName => edition.name;
  DateTime get editionStartDate => edition.initDate;
  DateTime get editionEndDate => edition.endDate;
  bool get isActive => edition.isActive;
  bool get isFinished => edition.isFinished;
}
