import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';
import 'package:guia_start/domain/repositories/third_party_repository.dart';
import 'package:guia_start/domain/usecases/fair/get_fair_with_organizer_usecase.dart';

class SearchFairsWithOrganizerUseCase
    implements UseCase<List<FairWithOrganizer>, String> {
  final FairRepository _fairRepository;
  final ThirdPartyRepository _thirdPartyRepository;

  SearchFairsWithOrganizerUseCase({
    required FairRepository fairRepository,
    required ThirdPartyRepository thirdPartyRepository,
  })  : _fairRepository = fairRepository,
        _thirdPartyRepository = thirdPartyRepository;

  @override
  Future<Result<List<FairWithOrganizer>>> call(String query) async {
// 1.  Buscar ferias por nombre
    final fairsResult = await _fairRepository.searchByName(query);

    if (fairsResult.isError) {
      return Result.failure(fairsResult.failure!);
    }

    final fairs = fairsResult.data!;
    final List<FairWithOrganizer> results = [];

// 2.  Para cada feria, obtener su orgnaizador
    for (final fair in fairs) {
      final organizerResult =
          await _thirdPartyRepository.getById(fair.organizerId);

      if (organizerResult.isSuccess) {
        results.add(FairWithOrganizer(
          fair: fair,
          organizer: organizerResult.data!,
        ));
      }
    }

    return Result.success(results);
  }
}
