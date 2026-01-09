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

  Future<Result<bool>> createUserProfile(UserProfile userProfile) async {
    try {
      await _db
          .collection(collectionPath)
          .doc(userProfile.id)
          .set(toMap(userProfile));
      return Result.success(true);
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

// Actualizar último login

  Future<Result<bool>> updateLastLogin(String userId) async {
    try {
      await _db.collection(collectionPath).doc(userId).update({
        'lastLoginAt': Timestamp.now(),
      });
      return Result.success(true);
    } catch (e) {
      return Result.error('Error al actualizar último login: $e');
    }
  }
}
