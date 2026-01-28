import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/edition.dart';
import 'package:guia_start/domain/repositories/edition_repository.dart';

/// Caso de uso para obtener todas las ediciones de una feria específica
class GetEditionsByFairUseCase
    implements UseCase<List<Edition>, GetEditionsByFairParams> {
  final EditionRepository editionRepository;

  GetEditionsByFairUseCase(this.editionRepository);

  @override
  Future<Result<List<Edition>>> call(GetEditionsByFairParams params) async {
    // Obtener ediciones de la feria
    final result = await editionRepository.getByFairId(params.fairId);

    if (result.isError) {
      return result;
    }

    // Ordenar por fecha de inicio (más reciente primero)
    final editions = result.data!;
    editions.sort((a, b) => b.initDate.compareTo(a.initDate));

    return Result.success(editions);
  }
}

class GetEditionsByFairParams {
  final String fairId;

  GetEditionsByFairParams({required this.fairId});
}
