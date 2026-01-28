import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/contact.dart';
import 'package:guia_start/domain/repositories/participation_repository.dart';

class AddContactUseCase implements UseCase<Contact, AddContactParams> {
  final ParticipationRepository _repository;

  AddContactUseCase(this._repository);

  @override
  Future<Result<Contact>> call(AddContactParams params) async {
    final contact = Contact(
      id: '',
      participationId: params.participationId,
      thirdPartyId: params.thirdPartyId,
      notes: params.notes,
      createdAt: DateTime.now(),
    );

    return await _repository.addContact(params.participationId, contact);
  }
}

class AddContactParams {
  final String participationId;
  final String thirdPartyId;
  final String? notes;

  AddContactParams({
    required this.participationId,
    required this.thirdPartyId,
    this.notes,
  });
}
