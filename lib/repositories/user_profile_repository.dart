import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/models/user_profile_model.dart';
import 'package:guia_start/repositories/base_repository.dart';
import 'package:guia_start/utils/result.dart';

class UserProfileRepository extends BaseRepository<UserProfile> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  String get collectionPath => 'users';

  @override
  UserProfile Function(Map<String, dynamic>) get fromMap => UserProfile.fromMap;

  @override
  Map<String, dynamic> Function(UserProfile) get toMap =>
      (user) => user.toMap();

  Future<Result<UserProfile>> createUserProfile(UserProfile userProfile) async {
    try {
      await _db
          .collection(collectionPath)
          .doc(userProfile.id)
          .set(toMap(userProfile));
      return Result.success(userProfile);
    } catch (e) {
      return Result.error('Error al crear perfil: $e');
    }
  }

  Future<Result<UserProfile>> getUserProfileByEmail(String email) async {
    try {
      final snapshot = await _db
          .collection(collectionPath)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return Result.error('Usuario no encontrado');
      }
      final doc = snapshot.docs.first;
      return Result.success(fromMap({
        ...doc.data(),
        'id': doc.id,
      }));
    } catch (e) {
      return Result.error('Error al obtener perfil: $e');
    }
  }

// Obtiene un perfil de usuario por su ID
  Future<Result<UserProfile>> getUserProfile(String userId) async {
    return await getById(userId);
  }

  // Stream de perfil de usuario por su ID
  Stream<UserProfile?> streamUserProfile(String userId) {
    return _db.collection(collectionPath).doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return fromMap({
        ...doc.data()!,
        'id': doc.id,
      });
    });
  }

  /// Actualiza el último acceso del usuario
  Future<Result<bool>> updateLastLogin(String userId) async {
    try {
      await _db.collection(collectionPath).doc(userId).update({
        'lastLoginAt': Timestamp.now(),
      });
      return Result.success(true);
    } catch (e) {
      return Result.error('Error al actualizar último acceso: $e');
    }
  }

  /// Actualiza el nombre de negocio del usuario
  Future<Result<bool>> updateBusinessName(
      String userId, String businessName) async {
    try {
      await _db.collection(collectionPath).doc(userId).update({
        'businessName': businessName,
      });
      return Result.success(true);
    } catch (e) {
      return Result.error('Error al actualizar nombre de negocio: $e');
    }
  }

  /// Actualiza la imagen de perfil del usuario
  Future<Result<bool>> updatePhotoUrl(String userId, String phtoUrl) async {
    try {
      await _db.collection(collectionPath).doc(userId).update({
        'photoUrl': phtoUrl,
      });
      return Result.success(true);
    } catch (e) {
      return Result.error('Error al actualizar imagen de perfil: $e');
    }
  }
}
