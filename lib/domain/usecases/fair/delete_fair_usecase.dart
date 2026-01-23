import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';

class DeleteFairUseCase implements UseCase<void, String> {
  final FairRepository _repository;

  DeleteFairUseCase(this._repository);

  @override
  Future<Result<void>> call(String fairId) async {
    // TODO:  Validar que no tenga ediciones asociadas antes de eliminar
    return await _repository.delete(fairId);
  }
}
