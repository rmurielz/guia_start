import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/data/datasources/firestore_datasource.dart';
import 'package:guia_start/data/models/user_profile_dto.dart';
import 'package:guia_start/domain/entities/user_profile.dart';
import 'package:guia_start/domain/repositories/user_repository.dart';
import 'package:guia_start/core/constants/firestore_collections.dart';

class UserRepositoryImpl implements UserRepository {
  final FirestoreDataSource _dataSource;

  UserRepositoryImpl({FirestoreDataSource? dataSource})
      : _dataSource = dataSource ?? FirestoreDataSource();

  @override
  Future<Result<UserProfile>> create(UserProfile user) async {
    try {
      // Usuario usa su propio ID (del auth), no autogenerado
      final dto = UserProfileDTO.fromEntity(user);
      await _dataSource.setDocument(
        FirestoreCollections.users,
        user.id,
        dto.toMap(),
      );

      return Result.success(user);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al crear perfil de usuario: $e'),
      );
    }
  }

  @override
  Future<Result<UserProfile>> getById(String id) async {
    try {
      final map = await _dataSource.getDocument(
        FirestoreCollections.users,
        id,
      );

      if (map == null) {
        return Result.failure(
          const NotFoundFailure('Usuario no encontrado'),
        );
      }

      final dto = UserProfileDTO.fromMap(map);
      return Result.success(dto.toEntity());
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener usuario: $e'),
      );
    }
  }

  @override
  Future<Result<UserProfile>> getByEmail(String email) async {
    try {
      final maps = await _dataSource.getDocumentsWhere(
        FirestoreCollections.users,
        'email',
        email,
      );

      if (maps.isEmpty) {
        return Result.failure(
          const NotFoundFailure('Usuario no encontrado'),
        );
      }

      final dto = UserProfileDTO.fromMap(maps.first);
      return Result.success(dto.toEntity());
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener usuario por email: $e'),
      );
    }
  }

  @override
  Future<Result<UserProfile>> update(UserProfile user) async {
    try {
      if (user.id.isEmpty) {
        return Result.failure(
          const ValidationFailure('ID de usuario no válido'),
        );
      }

      final dto = UserProfileDTO.fromEntity(user);
      await _dataSource.updateDocument(
        FirestoreCollections.users,
        user.id,
        dto.toMap(),
      );

      return Result.success(user);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al actualizar usuario: $e'),
      );
    }
  }

  @override
  Future<Result<void>> updateLastLogin(String userId) async {
    try {
      await _dataSource.updateDocument(
        FirestoreCollections.users,
        userId,
        {'lastLoginAt': Timestamp.now()},
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al actualizar último login: $e'),
      );
    }
  }

  @override
  Future<Result<void>> updateBusinessName(
    String userId,
    String businessName,
  ) async {
    try {
      await _dataSource.updateDocument(
        FirestoreCollections.users,
        userId,
        {'businessName': businessName},
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al actualizar nombre de negocio: $e'),
      );
    }
  }

  @override
  Future<Result<void>> updatePhotoUrl(String userId, String photoUrl) async {
    try {
      await _dataSource.updateDocument(
        FirestoreCollections.users,
        userId,
        {'photoUrl': photoUrl},
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al actualizar foto de perfil: $e'),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dataSource.deleteDocument(
        FirestoreCollections.users,
        id,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al eliminar usuario: $e'),
      );
    }
  }

  @override
  Stream<UserProfile?> watchById(String id) {
    return _dataSource.streamDocument(FirestoreCollections.users, id).map(
        (map) => map != null ? UserProfileDTO.fromMap(map).toEntity() : null);
  }
}
