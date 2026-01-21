import 'package:firebase_auth/firebase_auth.dart';
import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;

  AuthRepositoryImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  @override
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  @override
  Future<Result<String>> signUp({
    required String email,
    required String password,
    required String name,
    String? businessName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return Result.failure(
          const ServerFailure('No se pudo crear el usuario'),
        );
      }

      // Enviar email de verificación
      await user.sendEmailVerification();

      return Result.success(user.uid);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      return Result.failure(
        ServerFailure('Error inesperado al registrar: $e'),
      );
    }
  }

  @override
  Future<Result<String>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return Result.failure(
          const ServerFailure('No se pudo iniciar sesión'),
        );
      }

      return Result.success(user.uid);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      return Result.failure(
        ServerFailure('Error inesperado al iniciar sesión: $e'),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al cerrar sesión: $e'),
      );
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.failure(
          const UnauthorizedFailure('No hay usuario autenticado'),
        );
      }

      if (user.emailVerified) {
        return Result.failure(
          const ValidationFailure('El email ya está verificado'),
        );
      }

      await user.sendEmailVerification();
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al enviar email de verificación: $e'),
      );
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al enviar email de recuperación: $e'),
      );
    }
  }

  @override
  Stream<String?> watchAuthState() {
    return _auth.authStateChanges().map((user) => user?.uid);
  }

  /// Mapea excepciones de Firebase Auth a Failures del dominio
  Failure _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const NotFoundFailure('No existe una cuenta con ese correo');
      case 'wrong-password':
        return const UnauthorizedFailure('Contraseña incorrecta');
      case 'invalid-email':
        return const ValidationFailure('Correo electrónico no válido');
      case 'user-disabled':
        return const UnauthorizedFailure('Cuenta deshabilitada');
      case 'email-already-in-use':
        return const ValidationFailure('Correo ya registrado');
      case 'weak-password':
        return const ValidationFailure(
          'La contraseña debe tener mínimo 6 caracteres',
        );
      case 'operation-not-allowed':
        return const UnauthorizedFailure('Operación no permitida');
      case 'invalid-credential':
        return const UnauthorizedFailure('Credenciales inválidas');
      case 'too-many-requests':
        return const ServerFailure(
          'Demasiados intentos. Intenta de nuevo más tarde',
        );
      case 'network-request-failed':
        return const ServerFailure(
          'Error de conexión. Verifica tu internet',
        );
      default:
        return ServerFailure('Error de autenticación: ${e.code}');
    }
  }
}
