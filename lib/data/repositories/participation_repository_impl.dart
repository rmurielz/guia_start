import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/data/datasources/firestore_datasource.dart';
import 'package:guia_start/data/models/participation_dto.dart';
import 'package:guia_start/data/models/contact_dto.dart';
import 'package:guia_start/data/models/sale_dto.dart';
import 'package:guia_start/data/models/visitor_dto.dart';
import 'package:guia_start/domain/entities/participation.dart';
import 'package:guia_start/domain/entities/contact.dart';
import 'package:guia_start/domain/entities/sale.dart';
import 'package:guia_start/domain/entities/visitor.dart';
import 'package:guia_start/domain/repositories/participation_repository.dart';
import 'package:guia_start/core/constants/firestore_collections.dart';

class ParticipationRepositoryImpl implements ParticipationRepository {
  final FirestoreDatasource _dataSource;

  ParticipationRepositoryImpl({FirestoreDatasource? dataSource})
      : _dataSource = dataSource ?? FirestoreDatasource();

  // ===== PARTICIPACIONES =====

  @override
  Future<Result<Participation>> create(Participation participation) async {
    try {
      final dto = ParticipationDTO.fromEntity(participation);
      final id = await _dataSource.addDocument(
        FirestoreCollections.participations,
        dto.toMap(),
      );

      if (id == null) {
        return Result.failure(
          const ServerFailure('No se pudo crear la participación'),
        );
      }

      final created = participation.copyWith(id: id);
      return Result.success(created);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al crear participación: $e'),
      );
    }
  }

  @override
  Future<Result<Participation>> getById(String id) async {
    try {
      final map = await _dataSource.getDocument(
        FirestoreCollections.participations,
        id,
      );

      if (map == null) {
        return Result.failure(
          const NotFoundFailure('Participación no encontrada'),
        );
      }

      final dto = ParticipationDTO.fromMap(map);
      return Result.success(dto.toEntity());
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener participación: $e'),
      );
    }
  }

  @override
  Future<Result<List<Participation>>> getAll() async {
    try {
      final maps = await _dataSource.getDocuments(
        FirestoreCollections.participations,
      );

      final participations =
          maps.map((map) => ParticipationDTO.fromMap(map).toEntity()).toList();

      return Result.success(participations);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener participaciones: $e'),
      );
    }
  }

  @override
  Future<Result<List<Participation>>> getByUserId(String userId) async {
    try {
      final maps = await _dataSource.getDocumentsWhere(
        FirestoreCollections.participations,
        'userId',
        userId,
      );

      final participations =
          maps.map((map) => ParticipationDTO.fromMap(map).toEntity()).toList();

      return Result.success(participations);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener participaciones del usuario: $e'),
      );
    }
  }

  @override
  Future<Result<List<Participation>>> getByEditionId(String editionId) async {
    try {
      final maps = await _dataSource.getDocumentsWhere(
        FirestoreCollections.participations,
        'editionId',
        editionId,
      );

      final participations =
          maps.map((map) => ParticipationDTO.fromMap(map).toEntity()).toList();

      return Result.success(participations);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener participaciones de la edición: $e'),
      );
    }
  }

  @override
  Future<Result<Participation>> update(Participation participation) async {
    try {
      if (participation.id.isEmpty) {
        return Result.failure(
          const ValidationFailure('ID de participación no válido'),
        );
      }

      final dto = ParticipationDTO.fromEntity(participation);
      await _dataSource.updateDocument(
        FirestoreCollections.participations,
        participation.id,
        dto.toMap(),
      );

      return Result.success(participation);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al actualizar participación: $e'),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dataSource.deleteDocument(
        FirestoreCollections.participations,
        id,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al eliminar participación: $e'),
      );
    }
  }

  @override
  Stream<List<Participation>> watchByUserId(String userId) {
    return _dataSource
        .streamCollectionWhere(
          FirestoreCollections.participations,
          'userId',
          userId,
        )
        .map((maps) => maps
            .map((map) => ParticipationDTO.fromMap(map).toEntity())
            .toList());
  }

  // ===== CONTACTOS (SUBCOLLECTION) =====

  @override
  Future<Result<Contact>> addContact(
    String participationId,
    Contact contact,
  ) async {
    try {
      final dto = ContactDTO.fromEntity(contact);
      final id = await _dataSource.addToSubcollection(
        FirestoreCollections.participations,
        participationId,
        FirestoreCollections.contacts,
        dto.toMap(),
      );

      if (id == null) {
        return Result.failure(
          const ServerFailure('No se pudo agregar el contacto'),
        );
      }

      final created = contact.copyWith(id: id);
      return Result.success(created);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al agregar contacto: $e'),
      );
    }
  }

  @override
  Future<Result<List<Contact>>> getContacts(String participationId) async {
    try {
      final contacts = await _dataSource
          .streamSubcollection(
            FirestoreCollections.participations,
            participationId,
            FirestoreCollections.contacts,
          )
          .first;

      final entities =
          contacts.map((map) => ContactDTO.fromMap(map).toEntity()).toList();

      return Result.success(entities);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener contactos: $e'),
      );
    }
  }

  @override
  Stream<List<Contact>> watchContacts(String participationId) {
    return _dataSource
        .streamSubcollection(
          FirestoreCollections.participations,
          participationId,
          FirestoreCollections.contacts,
        )
        .map((maps) =>
            maps.map((map) => ContactDTO.fromMap(map).toEntity()).toList());
  }

  // ===== VENTAS (SUBCOLLECTION) =====

  @override
  Future<Result<Sale>> addSale(String participationId, Sale sale) async {
    try {
      final dto = SaleDTO.fromEntity(sale);
      final id = await _dataSource.addToSubcollection(
        FirestoreCollections.participations,
        participationId,
        FirestoreCollections.sales,
        dto.toMap(),
      );

      if (id == null) {
        return Result.failure(
          const ServerFailure('No se pudo agregar la venta'),
        );
      }

      final created = sale.copyWith(id: id);
      return Result.success(created);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al agregar venta: $e'),
      );
    }
  }

  @override
  Future<Result<List<Sale>>> getSales(String participationId) async {
    try {
      final sales = await _dataSource
          .streamSubcollection(
            FirestoreCollections.participations,
            participationId,
            FirestoreCollections.sales,
          )
          .first;

      final entities =
          sales.map((map) => SaleDTO.fromMap(map).toEntity()).toList();

      return Result.success(entities);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener ventas: $e'),
      );
    }
  }

  @override
  Stream<List<Sale>> watchSales(String participationId) {
    return _dataSource
        .streamSubcollection(
          FirestoreCollections.participations,
          participationId,
          FirestoreCollections.sales,
        )
        .map((maps) =>
            maps.map((map) => SaleDTO.fromMap(map).toEntity()).toList());
  }

  // ===== VISITANTES (SUBCOLLECTION) =====

  @override
  Future<Result<Visitor>> addVisitor(
    String participationId,
    Visitor visitor,
  ) async {
    try {
      final dto = VisitorDTO.fromEntity(visitor);
      final id = await _dataSource.addToSubcollection(
        FirestoreCollections.participations,
        participationId,
        FirestoreCollections.visitors,
        dto.toMap(),
      );

      if (id == null) {
        return Result.failure(
          const ServerFailure('No se pudo agregar el visitante'),
        );
      }

      final created = visitor.copyWith(id: id);
      return Result.success(created);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al agregar visitante: $e'),
      );
    }
  }

  @override
  Future<Result<List<Visitor>>> getVisitors(String participationId) async {
    try {
      final visitors = await _dataSource
          .streamSubcollection(
            FirestoreCollections.participations,
            participationId,
            FirestoreCollections.visitors,
          )
          .first;

      final entities =
          visitors.map((map) => VisitorDTO.fromMap(map).toEntity()).toList();

      return Result.success(entities);
    } catch (e) {
      return Result.failure(
        ServerFailure('Error al obtener visitantes: $e'),
      );
    }
  }

  @override
  Stream<List<Visitor>> watchVisitors(String participationId) {
    return _dataSource
        .streamSubcollection(
          FirestoreCollections.participations,
          participationId,
          FirestoreCollections.visitors,
        )
        .map((maps) =>
            maps.map((map) => VisitorDTO.fromMap(map).toEntity()).toList());
  }
}
