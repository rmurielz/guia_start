import 'package:guia_start/models/participation_model.dart';
import 'package:guia_start/repositories/base_repository.dart';
import 'package:guia_start/utils/result.dart';

class ParticipationRepository extends BaseRepository<Participation> {
  @override
  String get collectionPath => 'participations';

  @override
  Participation Function(Map<String, dynamic>) get fromMap =>
      Participation.fromMap;

  @override
  Map<String, dynamic> Function(Participation) get toMap => (p) => p.toMap();

  Future<Result<String>> saveParticipation(Participation participation) async {
    if (participation.id.isEmpty) {
      return await add(participation);
    } else {
      final updateResult = await update(participation.id, participation);
      return updateResult.isSuccess
          ? Result.success(participation.id)
          : Result.error(updateResult.error!);
    }
  }

  Future<Result<List<Participation>>> getParticipationsByUserId(
      String userId) async {
    try {
      final raw = await firestoreService.getDocumentsWhere(
          collectionPath, 'userId', userId);
      final items = raw.map((m) => fromMap(m)).toList();
      return Result.success(items);
    } catch (e) {
      return Result.error('Error al obtener participaciones $e');
    }
  }
}
