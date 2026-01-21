import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/user_profile.dart';

/// Contrato para operaciones de User
abstract class UserRepository {
  /// Crea un nuevo perfil de usuario
  Future<Result<UserProfile>> create(UserProfile user);

  /// Obtiene un usuario por ID
  Future<Result<UserProfile>> getById(String id);

  ///Obtiene un usuario por email
  Future<Result<UserProfile>> getByEmail(String email);

  /// Actualiza un perfil de usuario
  Future<Result<UserProfile>> update(UserProfile user);

  /// Actualiza la última fecha de login
  Future<Result<void>> updateLastLogin(String userId);

  /// Actualiza el nombre del negocio
  Future<Result<void>> updateBusinessName(String userId, String businessName);

  /// Actualiza url de la foto
  Future<Result<void>> updatePhotoUrl(String userId, String photoUrl);

  /// Elimina un usuario
  Future<Result<void>> delete(String id);

  /// Stream de un usuario específico
  Stream<Result<UserProfile?>> watchById(String id);
}
