import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/fair.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';

class GetFairUseCase implements UseCase<Fair, String> {
  final FairRepository _repository;

  GetFairUseCase(this._repository);

  @override
  Future<Result<Fair>> call(String fairId) async {
    return await _repository.getById(fairId);
  }
}
