import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/third_party.dart';
import 'package:guia_start/domain/repositories/third_party_repository.dart';

class CreateThirdPartyUseCase
    implements UseCase<ThirdParty, CreateThirdPartyParams> {
  final ThirdPartyRepository _repository;

  CreateThirdPartyUseCase(this._repository);

  @override
  Future<Result<ThirdParty>> call(CreateThirdPartyParams params) async {
    // 1. Validar email si existe
    if (params.contactEmail != null &&
        params.contactEmail!.isNotEmpty &&
        !_isValidEmail(params.contactEmail!)) {
      return Result.failure(
        const ValidationFailure('Formato de email inválido'),
      );
    }

    // 2. Validar duplicados por nombre
    final allResult = await _repository.getAll();

    if (allResult.isSuccess) {
      final isDuplicate = allResult.data!.any(
        (tp) => tp.name.toLowerCase() == params.name.toLowerCase(),
      );

      if (isDuplicate) {
        return Result.failure(
          const ValidationFailure('Ya existe un tercero con ese nombre'),
        );
      }
    }

    // 3. Crear tercero
    final thirdParty = ThirdParty(
      id: '',
      name: params.name.trim(),
      type: params.type,
      contactEmail: params.contactEmail?.trim(),
      contactPhone: params.contactPhone?.trim(),
      address: params.address?.trim(),
      notes: params.notes?.trim(),
      createdBy: params.createdBy,
      createdAt: DateTime.now(),
    );

    return await _repository.create(thirdParty);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    return emailRegex.hasMatch(email);
  }
}

class CreateThirdPartyParams {
  final String name;
  final ThirdPartyType type;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final String? notes;
  final String createdBy;

  CreateThirdPartyParams({
    required this.name,
    required this.type,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.notes,
    required this.createdBy,
  });
}
