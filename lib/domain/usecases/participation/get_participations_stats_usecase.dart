import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/repositories/participation_repository.dart';

class GetParticipationsStatsUseCase
    implements UseCase<ParticipationStats, GetStatsParams> {
  final ParticipationRepository _repository;

  GetParticipationsStatsUseCase(this._repository);

  @override
  Future<Result<ParticipationStats>> call(GetStatsParams params) async {
    // 1. Obtener la participación
    final participationResult =
        await _repository.getById(params.participationId);

    if (participationResult.isError) {
      return Result.failure(participationResult.failure!);
    }

    final participation = participationResult.data!;

    // 2. Obtener ventas
    final salesResult = await _repository.getSales(params.participationId);
    final sales = salesResult.isSuccess ? salesResult.data! : [];

    // 3. Obtener contactos
    final contactsResult =
        await _repository.getContacts(params.participationId);
    final contacts = contactsResult.isSuccess ? contactsResult.data! : [];

    // 4. Obtener visitantes
    final visitorsResult =
        await _repository.getVisitors(params.participationId);
    final visitors = visitorsResult.isSuccess ? visitorsResult.data! : [];

    // 5. Calcular estadísticas
    final totalSales = sales.fold<double>(0, (sum, sale) => sum + sale.amount);
    final totalContacts = contacts.length;
    final totalVisitors =
        visitors.fold<int>(0, (sum, v) => sum + v.count as int);
    final roi = participation.calculateROI(totalSales);

    final stats = ParticipationStats(
      participationId: params.participationId,
      totalSales: totalSales,
      salesCount: sales.length,
      contactsCount: totalContacts,
      visitorsCount: totalVisitors,
      participationCost: participation.participationCost,
      roi: roi,
    );

    return Result.success(stats);
  }
}

class GetStatsParams {
  final String participationId;

  GetStatsParams(this.participationId);
}

class ParticipationStats {
  final String participationId;
  final double totalSales;
  final int salesCount;
  final int contactsCount;
  final int visitorsCount;
  final double participationCost;
  final double roi;

  ParticipationStats({
    required this.participationId,
    required this.totalSales,
    required this.salesCount,
    required this.contactsCount,
    required this.visitorsCount,
    required this.participationCost,
    required this.roi,
  });
}
