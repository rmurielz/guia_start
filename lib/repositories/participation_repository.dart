import 'package:guia_start/models/participation_model.dart';
import 'package:guia_start/models/contact_model.dart';
import 'package:guia_start/models/sale_model.dart';
import 'package:guia_start/models/visitor_model.dart';
import 'package:guia_start/services/firestore_service.dart';

class ParticipationRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'participations';

// ========== PARTICIPATIONS ==========

// Crear o actualizar una participación
  Future<String?> addParticipation(Participation participation) async {
    if (participation.id.isEmpty) {
      return await _firestoreService.addDocument(
        _collection,
        participation.toMap(),
      );
    } else {
      final ok = await _firestoreService.updateDocument(
          _collection, participation.id, participation.toMap());
      return ok ? participation.id : '';
    }
  }

// Obtener todas las participaciones
  Future<List<Participation>> getParticipations() async {
    final raw = await _firestoreService.getDocuments(_collection);
    return raw.map((m) => Participation.fromMap(m)).toList();
  }

  // Obtener participaciones de un usuario específico
  Future<List<Participation>> getParticipationsByUserId(String userId) async {
    final raw = await _firestoreService.getDocumentsWhere(
      _collection,
      'userId',
      userId,
    );
    return raw.map((m) => Participation.fromMap(m)).toList();
  }

  // Obtener una participación por su ID
  Future<Participation?> getParticipationById(String id) async {
    final raw = await _firestoreService.getDocument(_collection, id);
    return raw != null ? Participation.fromMap(raw) : null;
  }

  // Actualizar participación
  Future<bool> updateParticipation(
      String id, Participation participation) async {
    return await _firestoreService.updateDocument(
        _collection, id, participation.toMap());
  }

  // Eliminar participación
  Future<bool> deleteParticipation(String id) async {
    return await _firestoreService.deleteDocument(_collection, id);
  }

  // Stream: Escuchar participaciones de un usuario específico
  Stream<List<Participation>> streamParticipationsByUserId(String userId) {
    return _firestoreService
        .streamCollectionWhere(_collection, 'userId', userId)
        .map((list) {
      return list.map((m) => Participation.fromMap(m)).toList();
    });
  }

// ========== CONTACTS (Subcolección) ==========

  String _contactsPath(String participationId) =>
      '$_collection/$participationId/contacts';

// Agregar un contacto a una participación
  Future<String?> addContact(String participationId, Contact contact) async {
    final path = _contactsPath(participationId);
    if (contact.id.isEmpty) {
      return await _firestoreService.addDocument(
        path,
        contact.toMap(),
      );
    } else {
      final ok = await _firestoreService.updateDocument(
          path, contact.id, contact.toMap());
      return ok ? contact.id : null;
    }
  }

// Obtener contactos de una participación
  Future<List<Contact>> getContacts(String participationId) async {
    final path = _contactsPath(participationId);
    final raw = await _firestoreService.getDocuments(path);
    return raw.map((m) => Contact.fromMap(m)).toList();
  }

// Obtener contacto por ID
  Future<Contact?> getContactById(
      String participationId, String contactId) async {
    final path = _contactsPath(participationId);
    final raw = await _firestoreService.getDocument(path, contactId);
    return raw != null ? Contact.fromMap(raw) : null;
  }

// Actualizar contacto
  Future<bool> updateContact(
      String participationId, String contactId, Contact contact) async {
    final path = _contactsPath(participationId);
    return await _firestoreService.updateDocument(
        path, contactId, contact.toMap());
  }

  // Eliminar contacto
  Future<bool> deleteContact(String participationId, String contactId) async {
    final path = _contactsPath(participationId);
    return await _firestoreService.deleteDocument(path, contactId);
  }

  // Stream: Escuchar contactos de una participación
  Stream<List<Contact>> streamContacts(String participationId) {
    final path = _contactsPath(participationId);
    return _firestoreService.streamCollection(path).map((list) {
      return list.map((m) => Contact.fromMap(m)).toList();
    });
  }

  // ========== SALES (Subcolección) ==========

  String _salesPath(String participationId) =>
      '$_collection/$participationId/sales';

// Agregar venta a una participación
  Future<String?> addSale(String participationId, Sale sale) async {
    final path = _salesPath(participationId);
    if (sale.id.isEmpty) {
      return await _firestoreService.addDocument(
        path,
        sale.toMap(),
      );
    } else {
      final ok =
          await _firestoreService.updateDocument(path, sale.id, sale.toMap());
      return ok ? sale.id : null;
    }
  }

  // Obtener ventas de una participación
  Future<List<Sale>> getSales(String participationId) async {
    final path = _salesPath(participationId);
    final raw = await _firestoreService.getDocuments(path);
    return raw.map((m) => Sale.fromMap(m)).toList();
  }

  // Obtener venta por ID
  Future<Sale?> getSaleById(String participationId, String saleId) async {
    final path = _salesPath(participationId);
    final raw = await _firestoreService.getDocument(path, saleId);
    return raw != null ? Sale.fromMap(raw) : null;
  }

  // Actualizar venta
  Future<bool> updateSale(
      String participationId, String saleId, Sale sale) async {
    final path = _salesPath(participationId);
    return await _firestoreService.updateDocument(path, saleId, sale.toMap());
  }

  // Eliminar venta
  Future<bool> deleteSale(String participationId, String saleId) async {
    final path = _salesPath(participationId);
    return await _firestoreService.deleteDocument(path, saleId);
  }

  // Stream: Escuchar ventas de una participación
  Stream<List<Sale>> streamSales(String participationId) {
    final path = _salesPath(participationId);
    return _firestoreService.streamCollection(path).map((list) {
      return list.map((m) => Sale.fromMap(m)).toList();
    });
  }

  // ========== VISITORS (Subcolección) ==========

  String _visitorsPath(String participationId) =>
      '$_collection/$participationId/visitors';

  // Agregar visitante a una participación
  Future<String?> addVisitor(String participationId, Visitor visitor) async {
    final path = _visitorsPath(participationId);
    if (visitor.id.isEmpty) {
      return await _firestoreService.addDocument(
        path,
        visitor.toMap(),
      );
    } else {
      final ok = await _firestoreService.updateDocument(
          path, visitor.id, visitor.toMap());
      return ok ? visitor.id : null;
    }
  }

  // Obtener visitantes de una participación
  Future<List<Visitor>> getVisitors(String participationId) async {
    final path = _visitorsPath(participationId);
    final raw = await _firestoreService.getDocuments(path);
    return raw.map((m) => Visitor.fromMap(m)).toList();
  }

  // Stream: Escuchar visitantes de una participación
  Stream<List<Visitor>> streamVisitors(String participationId) {
    final path = _visitorsPath(participationId);
    return _firestoreService.streamCollection(path).map((list) {
      return list.map((m) => Visitor.fromMap(m)).toList();
    });
  }

  // Eliminar visitante
  Future<bool> deleteVisitor(String participationId, String visitorId) async {
    final path = _visitorsPath(participationId);
    return await _firestoreService.deleteDocument(path, visitorId);
  }
}
