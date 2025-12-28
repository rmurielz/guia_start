import 'dart:async';

import 'package:guia_start/models/edition_model.dart';
import 'package:guia_start/services/firestore_service.dart';
import 'package:guia_start/constants/firestore_collections.dart';

class EditionRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = FirestoreCollections.editions;

// ============ CREATE/UPDATE ============

  Future<String?> addEdition(Edition edition) async {
    if (edition.id.isEmpty) {
      // Crear nueva edición (sin ID)
      return await _firestoreService.addDocument(_collection, edition.toMap());
    } else {
      // Actualizar edición existente (con ID)
      final ok = await _firestoreService.updateDocument(
        _collection,
        edition.id,
        edition.toMap(),
      );
      return ok ? edition.id : null;
    }
  }

  Future<bool> updateEdition(String id, Edition edition) async {
    return await _firestoreService.updateDocument(
        _collection, id, edition.toMap());
  }

// ============ READ ============

  Future<List<Edition>> getEditions() async {
    final raw = await _firestoreService.getDocuments(_collection);
    return raw.map((m) => Edition.fromMap(m)).toList();
  }

  // Query directo por fairId
  Future<List<Edition>> getEditionsByFairId(String fairId) async {
    final raw = await _firestoreService.getDocumentsWhere(
      _collection,
      'fairId',
      fairId,
    );

    return raw.map((m) => Edition.fromMap(m)).toList();
  }

  Future<Edition?> getEditionById(String id) async {
    final raw = await _firestoreService.getDocument(_collection, id);
    return raw != null ? Edition.fromMap(raw) : null;
  }

// ============ DELETE ============
  Future<bool> deleteEdition(String id) async {
    return await _firestoreService.deleteDocument(_collection, id);
  }
// ============ STREAMs ============

// Stream - Escuchar una edición en particular. Query directo por fairId

  Stream<List<Edition>> streamEditionsByFairId(String fairId) {
    return _firestoreService
        .streamCollectionWhere(_collection, 'fairId', fairId)
        .map((list) {
      return list.map((m) => Edition.fromMap(m)).toList();
    });
  }

  // Stream: Escuchar todas las ediciones
  Stream<List<Edition>> streamAllEditions() {
    return _firestoreService.streamCollection(_collection).map((list) {
      return list.map((m) => Edition.fromMap(m)).toList();
    });
  }
}
