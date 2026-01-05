// lib/repositories/fair_repository.dart

import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/repositories/base_repository.dart';

class FairRepository extends BaseRepository<Fair> {
  @override
  String get collectionPath => 'fairs';

  @override
  Fair Function(Map<String, dynamic>) get fromMap => Fair.fromMap;

  @override
  Map<String, dynamic> Function(Fair) get toMap => (fair) => fair.toMap();

  /// Buscar ferias por nombre
  Future<List<Fair>> searchFairByName(String query) async {
    final result = await getAll();
    if (result.isError) return [];

    return result.data!
        .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
