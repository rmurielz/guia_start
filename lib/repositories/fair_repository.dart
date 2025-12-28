// lib/repositories/fair_repository.dart

import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/services/firestore_service.dart';

class FairRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'fairs';

// ====== CREATE / UPDATE ======

// Crear o actualizar una feria
  Future<String?> addFair(Fair fair) async {
    if (fair.id.isEmpty) {
      // Crea nueva feria (sin ID)
      return await _firestoreService.addDocument(_collection, fair.toMap());
    } else {
      // Actualiza feria existente
      final ok = await _firestoreService.updateDocument(
          _collection, fair.id, fair.toMap());
      return ok ? fair.id : null;
    }
  }

  /// Actualizar feria
  Future<bool> updateFair(String id, Fair fair) async {
    return await _firestoreService.updateDocument(
        _collection, id, fair.toMap());
  }

// ====== READ ======

// Obtener todas las ferias
  Future<List<Fair>> getFairs() async {
    final raw = await _firestoreService.getDocuments(_collection);
    return raw.map((m) => Fair.fromMap(m)).toList();
  }

// Obtener una feria por su ID
  Future<Fair?> getFairById(String id) async {
    final raw = await _firestoreService.getDocument(_collection, id);
    return raw != null ? Fair.fromMap(raw) : null;
  }

// Obtener ferias creadas por un usario específico
  Future<List<Fair>> getFairsByCreator(String userId) async {
    final raw = await _firestoreService.getDocumentsWhere(
      _collection,
      'createdBy',
      userId,
    );
    return raw.map((m) => Fair.fromMap(m)).toList();
  }

// Buscar ferias por nombre (búsqueda en memoria)
  Future<List<Fair>> searchFairByName(String query) async {
    final all = await getFairs();
    final lowerQuery = query.toLowerCase();
    return all.where((f) => f.name.toLowerCase().contains(lowerQuery)).toList();
  }

// ====== DELETE ======

// Eliminar feria
  Future<bool> deleteFair(String id) async {
    return await _firestoreService.deleteDocument(_collection, id);
  }

//====== STREAMS ======

// Stream: Escuchar todas las ferias
  Stream<List<Fair>> streamFairs() {
    return _firestoreService.streamCollection(_collection).map((list) {
      return list.map((m) => Fair.fromMap(m)).toList();
    });
  }

// Stream: Escuchar ferias creadas por un usuario específico
  Stream<List<Fair>> streamFairsByCreator(String userId) {
    return _firestoreService
        .streamCollectionWhere(_collection, 'createdBy', userId)
        .map((list) {
      return list.map((m) => Fair.fromMap(m)).toList();
    });
  }
}
