import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// DataSource genérico para operaciones CRUF en firestore
///
/// Respoonsabilidades:
/// - Acceso directo a Firebase
/// - Operaciones CRUD genéricas
/// - Retorna Map<String, dynamic> (sin conocer entidades)
/// - Maneja errores de Firebase

class FirestoreDatasource {
  final FirebaseFirestore _db;

  FirestoreDatasource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // ========= CREATE =========

  /// Agrega un documento con ID autogenerado
  Future<String?> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await _db.collection(collectionPath).add(data);
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding document to $collectionPath: $e');
      rethrow;
    }
  }

  /// Crea documento con ID específico
  Future<void> setDocument(
    String collectionPath,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection(collectionPath).doc(id).set(data);
    } catch (e) {
      debugPrint('Error setting document to $collectionPath: $e');
      rethrow;
    }
  }

// ========= READ =========

  /// Obtiene todos los documentos de una colección
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
      debugPrint('Error getting documents from $collectionPath: $e');
      rethrow;
    }
  }

  /// Obtiene un documento por un ID
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
      debugPrint('Error getting document $id from $collectionPath: $e');
      rethrow;
    }
  }

  /// Obtiene documentos con filtro WHERE
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
          'Error getting documents where $field = $value from $collectionPath: $e');
      rethrow;
    }
  }

  /// Obtiene documentos cn múltiples filtros WHERE
  Future<List<Map<String, dynamic>>> getDocumentsWhereMultiple(
    String collectionPath,
    Map<String, dynamic> filters,
  ) async {
    try {
      Query query = _db.collection(collectionPath);

      filters.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      debugPrint(
          'Error getting documents with filters from $collectionPath: $e');
      rethrow;
    }
  }

// ======== UPDATE ========

  /// Actualiza documento por ID
  Future<void> updateDocument(
    String collectionPath,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection(collectionPath).doc(id).update(data);
    } catch (e) {
      debugPrint('Error updating document $id in $collectionPath: $e');
      rethrow;
    }
  }

// ========= DELETE =========

//Elimina documento por ID
  Future<void> deleteDocument(String collectionPath, String id) async {
    try {
      await _db.collection(collectionPath).doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting document $id from $collectionPath: $e');
      rethrow;
    }
  }

// ========= STREAMS =========

  /// Stream de todos los documentos de una colección
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

  // Stream de documentos con filtro WHERE
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

  /// Stream de un documento específico
  Stream<Map<String, dynamic>?> streamDocument(
    String collectionPath,
    String id,
  ) {
    return _db.collection(collectionPath).doc(id).snapshots().map((doc){
      if (!doc.exists) return null;
      return {'id': doc.id, ...doc.data()!}
    });
  }

// ====== BATCH OPERATIONS =======

/// Ejecuta múltiples operaciones en batch
Future<void> batchWrite(List<BatchOperation> operations) async {
  try{
    final batch = _db.batch();
    
    for (final operation in operations) {
      final docRef = _db.collection(operation.collectionPath).doc(operation.id);

      switch (operation.type){
        case BatchOperationType.set:
        batch.set(docRef, operation.data!);
        break;
        case BatchOperationType.update:
        batch.update(docRef, operation.data!);
        break;
        case BatchOperationType.delete:
        batch.delete(docRef);
        break;
      }
    }
    await batch.commit();
  } catch (e) {
    debugPrint('Error executing batch operations: $e');
    rethrow;
  }
}

//========= SUBCOLLECTIONS =========

/// Agrega un documento a una subcolección
Future<String?> addToSubcollection(

  String parentPath,
  String parentId,
  String subcollectionName,
  Map<String, dynamic> data, 
) async {
  try {
  final docRef = await _db
  .collection(parentPath)
  .doc(parentId)
  .collection(subcollectionName)
  .add(data);
  return docRef.id;
} catch (e){
  debugPrint('Error adding to subcollection $subcollectionName: $e');
  rethrow;
}
}

/// Stream de subcolección
Stream<List<Map<String, dynamic>>> streamSubcollection(
String parentPath,
String parentId,
String subcollectionName,
) {
  return _db
      .collection(parentPath)
      .doc(parentId)
      .collection(subcollectionName)
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
}

// ======== HELPERS ========

enum BatchOperationType { set, update, delete }

class BatchOperation{
  final String collectionPath;
  final String id;
  final BatchOperationType type;
  final Map<String, dynamic>? data;

  BatchOperation({
    required this.collectionPath,
    required this.id,
    required this.type,
    this.data
  });
}
