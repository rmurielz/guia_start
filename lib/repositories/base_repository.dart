import 'package:guia_start/services/firestore_service.dart';

abstract class BaseRepository<T> {
  final FirestoreService firestoreService = FirestoreService();

  String get collectionPath;
  T Function(Map<String, dynamic>) get fromMap;
  Map<String, dynamic> Function(T) get toMap;

  Future<String?> add(T item) async {
    return await firestoreService.addDocument(
      collectionPath,
      toMap(item),
    );
  }

  Future<List<T>> getAll() async {
    final raw = await firestoreService.getDocuments(collectionPath);
    return raw.map((doc) => fromMap(doc)).toList();
  }

  Future<T?> getById(String id) async {
    final raw = await firestoreService.getDocument(collectionPath, id);
    return raw != null ? fromMap(raw) : null;
  }

  Future<bool> update(String id, T item) async {
    return await firestoreService.updateDocument(
      collectionPath,
      id,
      toMap(item),
    );
  }

  Future<bool> delete(String id) async {
    return await firestoreService.deleteDocument(collectionPath, id);
  }

  Stream<List<T>> streamAll() {
    return firestoreService.streamCollection(collectionPath).map(
          (list) => list.map((m) => fromMap(m)).toList(),
        );
  }
}
