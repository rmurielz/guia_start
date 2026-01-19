import 'package:guia_start/models/edition_model.dart';
import 'package:guia_start/repositories/base_repository.dart';

class EditionRepository extends BaseRepository<Edition> {
  @override
  String get collectionPath => 'editions';

  @override
  Edition Function(Map<String, dynamic>) get fromMap => Edition.fromMap;

  @override
  Map<String, dynamic> Function(Edition) get toMap => (e) => e.toMap();

  Future<List<Edition>> getEditionsByFairId(String fairId) async {
    final raw = await firestoreService.getDocumentsWhere(
      collectionPath,
      'fairId',
      fairId,
    );
    return raw.map((m) => fromMap(m)).toList();
  }

  Stream<List<Edition>> streamEditionsByFairId(String fairId) {
    return firestoreService
        .streamCollectionWhere(collectionPath, 'fairId', fairId)
        .map((list) => list.map((m) => fromMap(m)).toList());
  }
}
