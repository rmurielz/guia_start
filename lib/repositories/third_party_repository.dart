import 'dart:async';

import 'package:guia_start/models/third_party_model.dart';
import 'package:guia_start/services/firestore_service.dart';
import 'package:guia_start/constants/firestore_collections.dart';

class ThirdPartyRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = FirestoreCollections.thirdParties;

  String _enumToString(ThirdPartyType type) {
    return type.toString().split('.').last;
  }

// ======== CREATE/UPDATE =========

  Future<String?> addThirdParty(ThirdParty thirdParty) async {
    if (thirdParty.id.isEmpty) {
      // Crea nuevo tercero (sin ID)
      return await _firestoreService.addDocument(
          _collection, thirdParty.toMap());
    } else {
      // Actualiza tercero existente
      final ok = await _firestoreService.updateDocument(
          _collection, thirdParty.id, thirdParty.toMap());
      return ok ? thirdParty.id : null;
    }
  }

  Future<bool> updateThirdParty(String id, ThirdParty thirdParty) async {
    return await _firestoreService.updateDocument(
        _collection, id, thirdParty.toMap());
  }

// ======== READ =========

  Future<List<ThirdParty>> getThirdParties() async {
    final raw = await _firestoreService.getDocuments(_collection);
    return raw.map((m) => ThirdParty.fromMap(m)).toList();
  }

  // Obtener un tercero por su ID
  Future<ThirdParty?> getThirdPartyById(String id) async {
    final raw = await _firestoreService.getDocument(_collection, id);
    return raw != null ? ThirdParty.fromMap(raw) : null;
  }

// Query directo por tipo
  Future<List<ThirdParty>> getThirdPartiesByType(ThirdPartyType type) async {
    final raw = await _firestoreService.getDocumentsWhere(
        _collection, 'type', _enumToString(type));
    return raw.map((m) => ThirdParty.fromMap(m)).toList();
  }

// Query directo por creador
  Future<List<ThirdParty>> getThirdPartiesByCreator(String userId) async {
    final raw = await _firestoreService.getDocumentsWhere(
        _collection, 'createdBy', userId);
    return raw.map((m) => ThirdParty.fromMap(m)).toList();
  }

// Búsqueda por no mbre (en memoria, limitación de Firestore)

  Future<List<ThirdParty>> searchThirdPartiesByName(String query) async {
    final all = await getThirdParties();
    final lowerQuery = query.toLowerCase();
    return all
        .where((tp) => tp.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

// ======== DELETE =========

  Future<bool> deleteThirdParty(String id) async {
    return await _firestoreService.deleteDocument(_collection, id);
  }

// ======== STREAMS =========
  Stream<List<ThirdParty>> streamThirdParties() {
    return _firestoreService.streamCollection(_collection).map((list) {
      return list.map((m) => ThirdParty.fromMap(m)).toList();
    });
  }

// Stream con query directo por tipo
  Stream<List<ThirdParty>> streamThirdPartiesByType(ThirdPartyType type) {
    return _firestoreService
        .streamCollectionWhere(_collection, 'type', _enumToString(type))
        .map((list) {
      return list.map((m) => ThirdParty.fromMap(m)).toList();
    });
  }
}
