import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/fair.dart';
import 'package:guia_start/domain/entities/third_party.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';
import 'package:guia_start/domain/repositories/third_party_repository.dart';

class GetFairWithOrganizerUsecase
    implements UseCase<FairWithOrganizer, String> {
  final FairRepository _fairRepository;
  final ThirdPartyRepository _thirdPartyRepository;

  GetFairWithOrganizerUsecase({
    required FairRepository fairRepository,
    required ThirdPartyRepository thirdPartyRepository,
  })  : _fairRepository = fairRepository,
        _thirdPartyRepository = thirdPartyRepository;

  @override
  Future<Result<FairWithOrganizer>> call(String fairId) async {
    // 1.  Obtener feria
    final fairResult = await _fairRepository.getById(fairId);

    if (fairResult.isError) {
      return Result.failure(fairResult.failure!);
    }

    final fair = fairResult.data!;

// 2. Obtener organizador
    final organizerResult =
        await _thirdPartyRepository.getById(fair.organizerId);

    if (organizerResult.isError) {
      return Result.failure(organizerResult.failure!);
    }

    return Result.success(
      FairWithOrganizer(
        fair: fair,
        organizer: organizerResult.data!,
      ),
    );
  }
}

/// DTO que combina Fair y ThirdParty (organizador)
class FairWithOrganizer {
  final Fair fair;
  final ThirdParty organizer;

  FairWithOrganizer({required this.fair, required this.organizer});
}
