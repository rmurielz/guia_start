import 'package:guia_start/models/third_party_model.dart';
import 'package:guia_start/repositories/base_repository.dart';

class ThirdPartyRepository extends BaseRepository<ThirdParty> {
  @override
  String get collectionPath => 'thirdParties';

  @override
  ThirdParty Function(Map<String, dynamic>) get fromMap => ThirdParty.fromMap;

  @override
  Map<String, dynamic> Function(ThirdParty) get toMap => (tp) => tp.toMap();

  String _enumToString(ThirdPartyType type) {
    return type.toString().split('.').last;
  }

  Future<List<ThirdParty>> getThirdPartiesById(ThirdPartyType type) async {
    final raw = await firestoreService.getDocumentsWhere(
      collectionPath,
      'type',
      _enumToString(type),
    );
    return raw.map((m) => fromMap(m)).toList();
  }

  Future<List<ThirdParty>> searchThirdPartiesByName(String query) async {
    final all = await getAll();
    return all
        .where((tp) => tp.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Stream<List<ThirdParty>> streamThirdPartiesByType(ThirdPartyType type) {
    return firestoreService
        .streamCollectionWhere(collectionPath, 'type', _enumToString(type))
        .map((list) => list.map((m) => fromMap(m)).toList());
  }

  Future<String?> addThirdParty(ThirdParty tp) => add(tp);
}
