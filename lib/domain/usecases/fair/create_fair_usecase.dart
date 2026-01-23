import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/fair.dart';
import 'package:guia_start/domain/entities/third_party.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';
import 'package:guia_start/domain/repositories/third_party_repository.dart';

class CreateFairUseCase implements UseCase<Fair, CreateFairParams> {
  final FairRepository _fairRepository;
  final ThirdPartyRepository _thirdPartyRepository;

  CreateFairUseCase({
    required FairRepository fairRepository,
    required ThirdPartyRepository thirdPartyRepository,
  })  : _fairRepository = fairRepository,
        _thirdPartyRepository = thirdPartyRepository;

  @override
  Future<Result<Fair>> call(CreateFairParams params) async {
    // 1. Validar que el organizador exista
    final organizerResult = await _thirdPartyRepository.getById(
      params.organizerId,
    );
    if (organizerResult.isError) {
      return Result.failure(const NotFoundFailure('Organizador no encontrado'));
    }

    final organizer = organizerResult.data!;

    // 2.  Validar que sea tipo organizado
    if (organizer.type != ThirdPartyType.organizer) {
      return Result.failure(
          const ValidationFailure('El tercero no es un organizador válido'));
    }

    // 3.  Validar duplicados por nombre y organizador
    final existingFair = await _fairRepository.getByOrganizer(
      params.organizerId,
    );

    if (existingFair.isSuccess) {
      final isDuplicate = existingFair.data!
          .any((fair) => fair.name.toLowerCase() == params.name.toLowerCase());

      if (isDuplicate) {
        return Result.failure(
          const ValidationFailure(
            'Ya existe una feria con ese nombre para este organizador',
          ),
        );
      }
    }
    //4.  Crear la feria
    final fair = Fair(
      id: 'id',
      name: params.name.trim(),
      description: params.description.trim(),
      organizerId: params.organizerId,
      createdBy: params.createdBy,
      isRecurring: params.isRecurring,
      createdAt: DateTime.now(),
    );

    return await _fairRepository.create(fair);
  }
}

class CreateFairParams {
  final String name;
  final String description;
  final String organizerId;
  final String createdBy;
  final bool isRecurring;

  CreateFairParams({
    required this.name,
    required this.description,
    required this.organizerId,
    required this.createdBy,
    required this.isRecurring,
  });
}
