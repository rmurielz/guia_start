import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/repositories/participation_repository.dart';

class CalculateROIUseCase implements UseCase<double, String> {
  final ParticipationRepository _repository;

  CalculateROIUseCase(this._repository);

  @override
  Future<Result<double>> call(String participationId) async {
    // 1. Obtener participación
    final participationResult = await _repository.getById(participationId);

    if (participationResult.isError) {
      return Result.failure(participationResult.failure!);
    }

    final participation = participationResult.data!;

    // 2. Obtener ventas totales
    final salesResult = await _repository.getSales(participationId);

    if (salesResult.isError) {
      return Result.failure(salesResult.failure!);
    }

    final totalSales = salesResult.data!.fold<double>(
      0,
      (sum, sale) => sum + sale.amount,
    );

    // 3. Calcular ROI usando método de la entidad
    final roi = participation.calculateROI(totalSales);

    return Result.success(roi);
  }
}
