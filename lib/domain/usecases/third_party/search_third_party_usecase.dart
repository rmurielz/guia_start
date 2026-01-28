import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/third_party.dart';
import 'package:guia_start/domain/repositories/third_party_repository.dart';

/// Caso de uso para buscar terceros (proveedores, organizadores, etc.)
/// por nombre o filtrar por tipo
class SearchThirdPartyUseCase
    implements UseCase<List<ThirdParty>, SearchThirdPartyParams> {
  final ThirdPartyRepository thirdPartyRepository;

  SearchThirdPartyUseCase(this.thirdPartyRepository);

  @override
  Future<Result<List<ThirdParty>>> call(SearchThirdPartyParams params) async {
    // Si hay query de búsqueda, buscar por nombre
    if (params.query != null && params.query!.isNotEmpty) {
      final result = await thirdPartyRepository.searchByName(params.query!);

      if (result.isError) {
        return result;
      }

      // Si además hay filtro de tipo, aplicarlo
      if (params.type != null) {
        final filtered =
            result.data!.where((tp) => tp.type == params.type).toList();
        return Result.success(filtered);
      }

      return result;
    }

    // Si solo hay filtro de tipo, obtener todos de ese tipo
    if (params.type != null) {
      return await thirdPartyRepository.getByType(params.type!.name);
    }

    // Si no hay filtros, obtener todos
    return await thirdPartyRepository.getAll();
  }
}

class SearchThirdPartyParams {
  final String? query;
  final ThirdPartyType? type;

  SearchThirdPartyParams({
    this.query,
    this.type,
  });

  // Factory methods para casos comunes
  factory SearchThirdPartyParams.byName(String query) {
    return SearchThirdPartyParams(query: query);
  }

  factory SearchThirdPartyParams.byType(ThirdPartyType type) {
    return SearchThirdPartyParams(type: type);
  }

  factory SearchThirdPartyParams.all() {
    return SearchThirdPartyParams();
  }
}
