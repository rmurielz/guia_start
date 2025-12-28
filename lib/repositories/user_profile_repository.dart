import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guia_start/models/user_profile_model.dart';
import 'package:guia_start/services/firestore_service.dart';

class UserProfileRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Crear perfil de usuario al registrarse
  Future<bool> createUserProfile(UserProfile userProfile) async {
    try {
      await _db
          .collection(_collection)
          .doc(userProfile.id)
          .set(userProfile.toMap());
      return true;
    } catch (e) {
      print('Error creating user profile: $e');
      return false;
    }
  }

  // Actualizar perfil de usuario
  Future<bool> updateUserProfile(String userId, UserProfile profile) async {
    return await _firestoreService.updateDocument(
        _collection, userId, profile.toMap());
  }

  // Eliminar perfil de usuario
  Future<bool> deleteUserProfile(String userId) async {
    return await _firestoreService.deleteDocument(_collection, userId);
  }

  // Actualizar fecha de último login
  Future<bool> updateLastLogin(String userId) async {
    try {
      final doc = await _db.collection(_collection).doc(userId).get();
      if (!doc.exists){
        print('User profile not found for ID: $userId');
         return false;
      }
      
      await _db
          .collection(_collection)
          .doc(userId)
          .update({'lastLoginAt': Timestamp.now()});
      return true;
    } catch (e) {
      print('Error updating last login: $e');
      return false;
    }
  }

// Obtener perfil de usuariopor ID
  Future<UserProfile?> getUserProfile(String userId) async {
    final raw = await _firestoreService.getDocument(_collection, userId);
    return raw != null ? UserProfile.fromMap(raw) : null;
  }

// Buscar perfil por email
  Future<UserProfile?> getUserProfileByEmail(String email) async {
    try {
      final snapshot = await _db
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return UserProfile.fromMap({
        'id': doc.id,
        ...doc.data(),
      });
    } catch (e) {
      print('Error fetching user profile by email: $e');
      return null;
    }
  }

  // Stream: Escuchar cambios en tiempo real del perfil de usuario
  Stream<UserProfile?> streamUserProfile(String userId) {
    return _db.collection(_collection).doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    });
  }
}
