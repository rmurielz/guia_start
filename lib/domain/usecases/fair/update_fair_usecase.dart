import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/fair.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';

class UpdateFairUsecase implements UseCase<Fair, Fair> {
  final FairRepository _repository;

  UpdateFairUsecase(this._repository);

  @override
  Future<Result<Fair>> call(Fair fair) async {
    return await _repository.update(fair);
  }
}
