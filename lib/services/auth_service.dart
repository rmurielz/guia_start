import 'package:firebase_auth/firebase_auth.dart';
import 'package:guia_start/models/user_profile_model.dart';
import 'package:guia_start/repositories/user_profile_repository.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserProfileRepository _userProfileRepo = UserProfileRepository();

// Obtener el usuario actual
  User? getCurrentUser() => _auth.currentUser;

// Escuchar cambios en el estado autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

// Registro con correo, contraseña y nombre
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    String? businessName,
  }) async {
    try {
      // 1.  Crear usuario en Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // 2.  Crear perfil en Firestore
        final userProfile = UserProfile(
          id: user.uid,
          name: name,
          email: email,
          businessName: businessName,
          createdAt: DateTime.now(),
        );

        final result = await _userProfileRepo.createUserProfile(userProfile);
        if (result.isError) {
          // Si hay error al crear el perfil, eliminar el usuario creado en Auth
          await user.delete();
          throw result.error!;
        }

        // 3.  Enviar email de verificación
        await user.sendEmailVerification();
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e.code);
    } catch (e) {
      throw e.toString();
    }
  }

// Inicio de sesión con correo y contraseña
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Actualizar fecha de último login
        await _userProfileRepo.updateLastLogin(user.uid);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reenviar email de verificación
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
// Recuperar contraseña

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }

// Obtener perfil de usuario desde Firestore
  Future<UserProfile?> getUserProfile(String userId) async {
    final result = await _userProfileRepo.getUserProfile(userId);
    return result.isSuccess ? result.data : null;
  }

// Stream del perfil de usuario
  Stream<UserProfile?> streamUserProfile(String userId) {
    return _userProfileRepo.streamUserProfile(userId);
  }

// Convertir códigos de error de Firebase en mensajes amigables

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo electrónico no válido';
      case 'user-disabled':
        return 'Cuenta deshabilitada';
      case 'email-already-in-use':
        return 'Correo ya registrado';
      case 'weak-password':
        return 'La contraseña debe tener mínimo 6 caracteres';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      case 'too-many-request':
        return 'Demasiados  intentos.  Prueba de nuevo más tarde';
      case 'network-request-failed':
        return 'Error de conexión, verifica tu internet';
      default:
        return 'Error de autenticación: $code';
    }
  }
}
