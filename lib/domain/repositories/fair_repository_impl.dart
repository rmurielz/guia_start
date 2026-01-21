import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/data/datasources/firestore_datasource.dart';
import 'package:guia_start/data/models/fair_dto.dart';
import 'package:guia_start/domain/entities/fair.dart';
import 'package:guia_start/domain/repositories/fair_repository.dart';
import 'package:guia_start/core/constants/firestore_collections.dart';

class FairRepositoryImpl implements FairRepository {
  final FirestoreDataSource _dataSource;

  FairRepositoryImpl({FirestoreDataSource? dataSource})
      : _dataSource = dataSource ?? FirestoreDataSource();

  @override
  Future<Result<Fair>> create(Fair fair) async {
    try {
      final dto = FairDTO.fromEntity(fair);
      final id = await _dataSource.addDocument(
        FirestoreCollections.fairs,
        dto.toMap(),
      );

      if (id == null) {
        return Result.failure(
          const ServerFailure('No se pudo crear la feria'),
        );
      }

      final createdFair = fair.copyWith(id: id);
      return Result.success(createdFair);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al crear feria: $e'),
      );
    }
  }

  @override
  Future<Result<Fair>> getById(String id) async {
    try {
      final map = await _dataSource.getDocument(
        FirestoreCollections.fairs,
        id,
      );

      if (map == null) {
        return Result.failure(
          const NotFoundFailure('Feria no encontrada'),
        );
      }

      final dto = FairDTO.fromMap(map);
      return Result.success(dto.toEntity());
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener feria: $e'),
      );
    }
  }

  @override
  Future<Result<List<Fair>>> getAll() async {
    try {
      final maps = await _dataSource.getDocuments(
        FirestoreCollections.fairs,
      );

      final fairs = maps.map((map) => FairDTO.fromMap(map).toEntity()).toList();

      return Result.success(fairs);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener ferias: $e'),
      );
    }
  }

  @override
  Future<Result<List<Fair>>> searchByName(String query) async {
    try {
      final allResult = await getAll();

      if (allResult.isError) {
        return Result.failure(allResult.failure!);
      }

      final filtered = allResult.data!
          .where(
              (fair) => fair.name.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return Result.success(filtered);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al buscar ferias: $e'),
      );
    }
  }

  @override
  Future<Result<List<Fair>>> getByOrganizer(String organizerId) async {
    try {
      final maps = await _dataSource.getDocumentsWhere(
        FirestoreCollections.fairs,
        'organizerId',
        organizerId,
      );

      final fairs = maps.map((map) => FairDTO.fromMap(map).toEntity()).toList();

      return Result.success(fairs);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener ferias del organizador: $e'),
      );
    }
  }

  @override
  Future<Result<Fair>> update(Fair fair) async {
    try {
      if (fair.id.isEmpty) {
        return Result.failure(
          const ValidationFailure('ID de feria no válido'),
        );
      }

      final dto = FairDTO.fromEntity(fair);
      await _dataSource.updateDocument(
        FirestoreCollections.fairs,
        fair.id,
        dto.toMap(),
      );

      return Result.success(fair);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al actualizar feria: $e'),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dataSource.deleteDocument(
        FirestoreCollections.fairs,
        id,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al eliminar feria: $e'),
      );
    }
  }

  @override
  Stream<List<Fair>> watchAll() {
    return _dataSource.streamCollection(FirestoreCollections.fairs).map(
        (maps) => maps.map((map) => FairDTO.fromMap(map).toEntity()).toList());
  }

  @override
  Stream<Fair?> watchById(String id) {
    return _dataSource
        .streamDocument(FirestoreCollections.fairs, id)
        .map((map) => map != null ? FairDTO.fromMap(map).toEntity() : null);
  }
}
