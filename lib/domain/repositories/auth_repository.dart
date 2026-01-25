import 'package:guia_start/core/utils/result.dart';

/// Contrato para operaciones de autenticación
abstract class AuthRepository {
  /// Obtiene el ID del usuario actual
  String? getCurrentUserId();

  /// Registro de un nuevo usuario
  Future<Result<String>> signUp({
    required String email,
    required String password,
    required String name,
    String? businessName,
  });

  /// Inicia sesión
  Future<Result<String>> signIn({
    required String email,
    required String password,
  });

  /// Cierra sesión
  Future<Result<void>> signOut();

  /// Envía email de verificación
  Future<Result<void>> sendEmailVerification();

  /// Envía email para recuperar contraseña
  Future<Result<void>> sendPasswordResetEmail(String email);

  /// Stream del estado actual de autenticación (userID o null)
  Stream<String?> watchAuthState();
}
