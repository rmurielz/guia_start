import 'package:guia_start/services/firestore_service.dart';
import 'package:guia_start/utils/result.dart';

abstract class BaseRepository<T> {
  final FirestoreService firestoreService = FirestoreService();

  String get collectionPath;
  T Function(Map<String, dynamic>) get fromMap;
  Map<String, dynamic> Function(T) get toMap;

  Future<Result<String>> add(T item) async {
    try {
      final id =
          await firestoreService.addDocument(collectionPath, toMap(item));
      return id != null
          ? Result.success(id)
          : Result.error('No se pudo crear el documento');
    } catch (e) {
      return Result.error('Error al crear $e');
    }
  }

  Future<Result<List<T>>> getAll() async {
    try {
      final raw = await firestoreService.getDocuments(collectionPath);
      final items = raw.map((doc) => fromMap(doc)).toList();
      return Result.success(items);
    } catch (e) {
      return Result.error('Error al obtener datos: $e');
    }
  }

  Future<Result<T>> getById(String id) async {
    try {
      final raw = await firestoreService.getDocument(collectionPath, id);
      if (raw != null) {
        return Result.success(fromMap(raw));
      }
      return Result.error('No se encontro el documento');
    } catch (e) {
      return Result.error('Error al obtener datos: $e');
    }
  }

  Future<Result<bool>> update(String id, T item) async {
    try {
      final success = await firestoreService.updateDocument(
        collectionPath,
        id,
        toMap(item),
      );
      return success
          ? Result.success(true)
          : Result.error('No se pudo actualizar el documento');
    } catch (e) {
      return Result.error('Error al actualizar: $e');
    }
  }

  Future<Result<bool>> delete(String id) async {
    try {
      final success = await firestoreService.deleteDocument(collectionPath, id);
      return success
          ? Result.success(true)
          : Result.error('No se pudo eliminar el documento');
    } catch (e) {
      return Result.error('Error al eliminar: $e');
    }
  }

  Stream<List<T>> streamAll() {
    return firestoreService.streamCollection(collectionPath).map(
          (list) => list.map((m) => fromMap(m)).toList(),
        );
  }
}
