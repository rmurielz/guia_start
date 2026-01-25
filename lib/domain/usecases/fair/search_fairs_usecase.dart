import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/fair.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';

class SearchFairsUsecase implements UseCase<List<Fair>, String> {
  final FairRepository _repository;

  SearchFairsUsecase(this._repository);

  @override
  Future<Result<List<Fair>>> call(String query) async {
    return await _repository.searchByName(query);
  }
}
