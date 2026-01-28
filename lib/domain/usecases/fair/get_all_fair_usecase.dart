import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/fair.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';

class GetAllFairsUseCase implements UseCase<List<Fair>, NoParams> {
  final FairRepository _repository;

  GetAllFairsUseCase(this._repository);

  @override
  Future<Result<List<Fair>>> call(NoParams params) async {
    return await _repository.getAll();
  }
}
