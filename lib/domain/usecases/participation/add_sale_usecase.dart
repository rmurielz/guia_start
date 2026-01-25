import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/sale.dart';
import 'package:guia_start/domain/repositories/participation_repository.dart';

class AddSaleUseCase implements UseCase<Sale, AddSaleParams> {
  final ParticipationRepository _repository;

  AddSaleUseCase(this._repository);

  @override
  Future<Result<Sale>> call(AddSaleParams params) async {
    final sale = Sale(
        id: '',
        participationId: params.participationId,
        amount: params.amount,
        paymentMethod: params.paymentMethod,
        products: params.products,
        contactId: params.contactId,
        notes: params.notes,
        createdAt: DateTime.now());

    return await _repository.addSale(params.participationId, sale);
  }
}

class AddSaleParams {
  final String participationId;
  final double amount;
  final PaymentMethod paymentMethod;
  final String products;
  final String? contactId;
  final String? notes;

  AddSaleParams({
    required this.participationId,
    required this.amount,
    required this.paymentMethod,
    required this.products,
    this.contactId,
    this.notes,
  });
}
