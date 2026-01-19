import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Servicio genérico para manejar operaciones CRUD en Firestore con queries optimizados

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========= CREATE =========

  // Agregar un documento con un ID Autogenerado

  Future<String?> addDocument(
      String collectionPath, Map<String, dynamic> data) async {
    try {
      final docRef = await _db.collection(collectionPath).add(data);
      return docRef.id;
    } catch (e) {
      debugPrint('Error al agregar documento en $collectionPath: $e');
      return null;
    }
  }

// Crear documento con un ID específico

  Future<bool> setDocument(
      String collectionPath, String id, Map<String, dynamic> data) async {
    try {
      await _db.collection(collectionPath).doc(id).set(data);
      return true;
    } catch (e) {
      debugPrint('Error al crear el documento $id en $collectionPath: $e');
      return false;
    }
  }

// ========= READ =========

// Obtener todos los documentos de una colección
  Future<List<Map<String, dynamic>>> getDocuments(
    String collectionPath,
  ) async {
    try {
      final snapshot = await _db.collection(collectionPath).get();
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      debugPrint('Error al obtener documentos de $collectionPath: $e');
      return [];
    }
  }

  /// Obtener un documento por ID
  Future<Map<String, dynamic>?> getDocument(
    String collectionPath,
    String id,
  ) async {
    try {
      final doc = await _db.collection(collectionPath).doc(id).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener el documento $id de $collectionPath: $e');
      return null;
    }
  }

// Obtener documentos con filtro WHERE
  Future<List<Map<String, dynamic>>> getDocumentsWhere(
    String collectionPath,
    String field,
    dynamic value,
  ) async {
    try {
      final snapshot = await _db
          .collection(collectionPath)
          .where(field, isEqualTo: value)
          .get();
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      debugPrint(
          'Error al obtener documentos con filtro WHERE: $field=$value en $collectionPath');
      return [];
    }
  }

  // Buscar documentos por campo de texto (contiene)
  // Firestore no soporta LIKE, esta es una búqueda simple
  Future<List<Map<String, dynamic>>> searchDocuments(
    String collectionPath,
    String field,
    String searchTerm,
  ) async {
    try {
      final lowerSearch = searchTerm.toLowerCase();
      final snapshot = await _db
          .collection(collectionPath)
          .where(field, isLessThanOrEqualTo: '$lowerSearch\uf8ff')
          .get();
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      debugPrint(
          'Error al buscar documentos $field=$searchTerm en $collectionPath: $e');
      return [];
    }
  }

// ========= UPDATE =========

  /// Actualizar documento por ID
  Future<bool> updateDocument(
    String collectionPath,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection(collectionPath).doc(id).update(data);
      return true;
    } catch (e) {
      debugPrint(
          'Error al actualizar documento con ID $id en $collectionPath: $e');
      return false;
    }
  }

// ========= DELETE =========

// Eliminar documento por ID
  Future<bool> deleteDocument(String collectionPath, String id) async {
    try {
      await _db.collection(collectionPath).doc(id).delete();
      return true;
    } catch (e) {
      debugPrint(
          'Error al eliminar documento con ID $id de $collectionPath: $e');
      return false;
    }
  }

// ========= STREAMS =========

// Escuchar cambios en una colección en tiempo real
  Stream<List<Map<String, dynamic>>> streamCollection(String collectionPath) {
    return _db.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    });
  }

  /// Escuchar cambios en documentos filtrados
  Stream<List<Map<String, dynamic>>> streamCollectionWhere(
    String collectionPath,
    String field,
    dynamic value,
  ) {
    return _db
        .collection(collectionPath)
        .where(field, isEqualTo: value)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    });
  }

// Escribir cambios en un documento específico
  Stream<Map<String, dynamic>?> streamDocument(
    String collectionPath,
    String id,
  ) {
    return _db.collection(collectionPath).doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return {'id': doc.id, ...doc.data()!};
    });
  }
}
