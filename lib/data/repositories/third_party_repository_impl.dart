import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/data/datasources/firestore_datasource.dart';
import 'package:guia_start/data/models/third_party_dto.dart';
import 'package:guia_start/domain/entities/third_party.dart';
import 'package:guia_start/domain/repositories/third_party_repository.dart';
import 'package:guia_start/core/constants/firestore_collections.dart';

class ThirdPartyRepositoryImpl implements ThirdPartyRepository {
  final FirestoreDatasource _dataSource;

  ThirdPartyRepositoryImpl({FirestoreDatasource? dataSource})
      : _dataSource = dataSource ?? FirestoreDatasource();

  @override
  Future<Result<ThirdParty>> create(ThirdParty thirdParty) async {
    try {
      final dto = ThirdPartyDTO.fromEntity(thirdParty);
      final id = await _dataSource.addDocument(
        FirestoreCollections.thirdParties,
        dto.toMap(),
      );

      if (id == null) {
        return Result.failure(
          const ServerFailure('No se pudo crear el tercero'),
        );
      }

      final created = thirdParty.copyWith(id: id);
      return Result.success(created);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al crear tercero: $e'),
      );
    }
  }

  @override
  Future<Result<ThirdParty>> getById(String id) async {
    try {
      final map = await _dataSource.getDocument(
        FirestoreCollections.thirdParties,
        id,
      );

      if (map == null) {
        return Result.failure(
          const NotFoundFailure('Tercero no encontrado'),
        );
      }

      final dto = ThirdPartyDTO.fromMap(map);
      return Result.success(dto.toEntity());
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener tercero: $e'),
      );
    }
  }

  @override
  Future<Result<List<ThirdParty>>> getAll() async {
    try {
      final maps = await _dataSource.getDocuments(
        FirestoreCollections.thirdParties,
      );

      final thirdParties =
          maps.map((map) => ThirdPartyDTO.fromMap(map).toEntity()).toList();

      return Result.success(thirdParties);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener terceros: $e'),
      );
    }
  }

  @override
  Future<Result<List<ThirdParty>>> getByType(String type) async {
    try {
      final maps = await _dataSource.getDocumentsWhere(
        FirestoreCollections.thirdParties,
        'type',
        type,
      );

      final thirdParties =
          maps.map((map) => ThirdPartyDTO.fromMap(map).toEntity()).toList();

      return Result.success(thirdParties);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener terceros por tipo: $e'),
      );
    }
  }

  @override
  Future<Result<List<ThirdParty>>> searchByName(String query) async {
    try {
      final allResult = await getAll();

      if (allResult.isError) {
        return Result.failure(allResult.failure!);
      }

      final filtered = allResult.data!
          .where((tp) => tp.name.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return Result.success(filtered);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al buscar terceros: $e'),
      );
    }
  }

  @override
  Future<Result<ThirdParty>> update(ThirdParty thirdParty) async {
    try {
      if (thirdParty.id.isEmpty) {
        return Result.failure(
          const ValidationFailure('ID de tercero no válido'),
        );
      }

      final dto = ThirdPartyDTO.fromEntity(thirdParty);
      await _dataSource.updateDocument(
        FirestoreCollections.thirdParties,
        thirdParty.id,
        dto.toMap(),
      );

      return Result.success(thirdParty);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al actualizar tercero: $e'),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dataSource.deleteDocument(
        FirestoreCollections.thirdParties,
        id,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al eliminar tercero: $e'),
      );
    }
  }

  @override
  Stream<List<ThirdParty>> watchByType(ThirdPartyType type) {
    return _dataSource
        .streamCollectionWhere(
          FirestoreCollections.thirdParties,
          'type',
          type.name,
        )
        .map((maps) =>
            maps.map((map) => ThirdPartyDTO.fromMap(map).toEntity()).toList());
  }

  @override
  Stream<ThirdParty?> watchById(String id) {
    return _dataSource
        .streamDocument(FirestoreCollections.thirdParties, id)
        .map((map) =>
            map != null ? ThirdPartyDTO.fromMap(map).toEntity() : null);
  }
}
