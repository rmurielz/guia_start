import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/data/datasources/firestore_datasource.dart';
import 'package:guia_start/data/models/edition_dto.dart';
import 'package:guia_start/domain/entities/edition.dart';
import 'package:guia_start/domain/repositories/edition_repository.dart';
import 'package:guia_start/core/constants/firestore_collections.dart';

class EditionRepositoryImpl implements EditionRepository {
  final FirestoreDatasource _dataSource;

  EditionRepositoryImpl({FirestoreDatasource? dataSource})
      : _dataSource = dataSource ?? FirestoreDatasource();

  @override
  Future<Result<Edition>> create(Edition edition) async {
    try {
      final dto = EditionDTO.fromEntity(edition);
      final id = await _dataSource.addDocument(
        FirestoreCollections.editions,
        dto.toMap(),
      );

      if (id == null) {
        return Result.failure(
          const ServerFailure('No se pudo crear la edición'),
        );
      }

      final createdEdition = edition.copyWith(id: id);
      return Result.success(createdEdition);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al crear edición: $e'),
      );
    }
  }

  @override
  Future<Result<Edition>> getById(String id) async {
    try {
      final map = await _dataSource.getDocument(
        FirestoreCollections.editions,
        id,
      );

      if (map == null) {
        return Result.failure(
          const NotFoundFailure('Edición no encontrada'),
        );
      }

      final dto = EditionDTO.fromMap(map);
      return Result.success(dto.toEntity());
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener edición: $e'),
      );
    }
  }

  @override
  Future<Result<List<Edition>>> getAll() async {
    try {
      final maps = await _dataSource.getDocuments(
        FirestoreCollections.editions,
      );

      final editions =
          maps.map((map) => EditionDTO.fromMap(map).toEntity()).toList();

      return Result.success(editions);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener ediciones: $e'),
      );
    }
  }

  @override
  Future<Result<List<Edition>>> getByFairId(String fairId) async {
    try {
      final maps = await _dataSource.getDocumentsWhere(
        FirestoreCollections.editions,
        'fairId',
        fairId,
      );

      final editions =
          maps.map((map) => EditionDTO.fromMap(map).toEntity()).toList();

      return Result.success(editions);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener ediciones de la feria: $e'),
      );
    }
  }

  @override
  Future<Result<List<Edition>>> getActive() async {
    try {
      final maps = await _dataSource.getDocumentsWhere(
        FirestoreCollections.editions,
        'status',
        'active',
      );

      final editions =
          maps.map((map) => EditionDTO.fromMap(map).toEntity()).toList();

      return Result.success(editions);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener ediciones activas: $e'),
      );
    }
  }

  @override
  Future<Result<Edition>> update(Edition edition) async {
    try {
      if (edition.id.isEmpty) {
        return Result.failure(
          const ValidationFailure('ID de edición no válido'),
        );
      }

      final dto = EditionDTO.fromEntity(edition);
      await _dataSource.updateDocument(
        FirestoreCollections.editions,
        edition.id,
        dto.toMap(),
      );

      return Result.success(edition);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al actualizar edición: $e'),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dataSource.deleteDocument(
        FirestoreCollections.editions,
        id,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al eliminar edición: $e'),
      );
    }
  }

  @override
  Stream<List<Edition>> watchByFairId(String fairId) {
    return _dataSource
        .streamCollectionWhere(
          FirestoreCollections.editions,
          'fairId',
          fairId,
        )
        .map((maps) =>
            maps.map((map) => EditionDTO.fromMap(map).toEntity()).toList());
  }

  @override
  Stream<Edition?> watchById(String id) {
    return _dataSource
        .streamDocument(FirestoreCollections.editions, id)
        .map((map) => map != null ? EditionDTO.fromMap(map).toEntity() : null);
  }
}
