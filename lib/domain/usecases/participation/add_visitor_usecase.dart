import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/visitor.dart';
import 'package:guia_start/domain/repositories/participation_repository.dart';

class AddVisitorUseCase implements UseCase<Visitor, AddVisitorParams> {
  final ParticipationRepository _repository;

  AddVisitorUseCase(this._repository);

  @override
  Future<Result<Visitor>> call(AddVisitorParams params) async {
    final visitor = Visitor(
      id: 'id',
      participationId: params.participationId,
      count: params.count,
      notes: params.notes,
      timestamp: DateTime.now(),
    );

    return await _repository.addVisitor(params.participationId, visitor);
  }
}

class AddVisitorParams {
  final String participationId;
  final int count;
  final String? notes;

  AddVisitorParams({
    required this.participationId,
    required this.count,
    this.notes,
  });
}
