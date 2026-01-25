import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/edition.dart';
import 'package:guia_start/domain/repositories/edition_repository.dart';

class ValidateEditionDatesUseCase
    implements UseCase<bool, ValidateEditionDatesParams> {
  final EditionRepository _repository;

  ValidateEditionDatesUseCase(this._repository);

  @override
  Future<Result<bool>> call(ValidateEditionDatesParams params) async {
    // 1. Validar que las fechas sean coherentes
    if (!params.endDate.isAfter(params.initDate)) {
      return Result.failure(
        const ValidationFailure(
            'La fecha de fin debe ser posterior a la fecha de inicio'),
      );
    }

    // 2. Obtener ediciones existentes de la misma feria
    final editionsResult = await _repository.getByFairId(params.fairId);

    if (editionsResult.isError) {
      return Result.failure(editionsResult.failure!);
    }

    // 3. Verificar solapamiento con otras ediciones
    for (final edition in editionsResult.data!) {
      // Saltar la edición actual si estamos editando
      if (params.currentEditionId != null &&
          edition.id == params.currentEditionId) {
        continue;
      }

      // Crear edición temporal para comparar
      final tempEdition = Edition(
        id: 'temp',
        fairId: params.fairId,
        name: '',
        location: '',
        initDate: params.initDate,
        endDate: params.endDate,
        createdBy: '',
        createdAt: DateTime.now(),
        status: EditionStatus.planning,
      );

      if (tempEdition.overlaps(edition)) {
        return Result.failure(
          ValidationFailure(
            'Las fechas se solapan con la edición "${edition.name}" (${edition.initDate.day}/${edition.initDate.month}/${edition.initDate.year} - ${edition.endDate.day}/${edition.endDate.month}/${edition.endDate.year})',
          ),
        );
      }
    }

    return Result.success(true);
  }
}

class ValidateEditionDatesParams {
  final String fairId;
  final DateTime initDate;
  final DateTime endDate;
  final String? currentEditionId; // null si es nueva edición

  ValidateEditionDatesParams({
    required this.fairId,
    required this.initDate,
    required this.endDate,
    this.currentEditionId,
  });
}
