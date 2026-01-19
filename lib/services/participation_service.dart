import 'package:guia_start/models/participation_model.dart';
import 'package:guia_start/models/edition_model.dart';
import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/models/contact_model.dart';
import 'package:guia_start/models/sale_model.dart';
import 'package:guia_start/models/visitor_model.dart';
import 'package:guia_start/repositories/participation_repository.dart';
import 'package:guia_start/repositories/edition_repository.dart';
import 'package:guia_start/repositories/fair_repository.dart';
import 'package:guia_start/utils/result.dart';

/// DTO para crear unaparticipación

class CreateParticipationRequest {
  final String userId;
  final String fairId;
  final String editionId;
  final String? boothNumber;
  final double particpationCost;

  CreateParticipationRequest({
    required this.userId,
    required this.fairId,
    required this.editionId,
    this.boothNumber,
    required this.particpationCost,
  });
}

/// DTO con datos completos de una participación, feria y edición
class ParticipationDetails {
  final Participation participation;
  final Fair fair;
  final Edition edition;

  ParticipationDetails({
    required this.participation,
    required this.fair,
    required this.edition,
  });
}

/// Service que maneja la lógica de negocio de participaciones
///
/// Responsabilidades:
/// - Vaildar que feria y edición existan
/// - Validar que no haya participación duplicada
/// - Gestionar subcolecciones (contactos, ventas, visitantes)
/// - Calcular estadísticas

class ParticipationService {
  final ParticipationRepository _participationRepo = ParticipationRepository();
  final FairRepository _fairRepo = FairRepository();
  final EditionRepository _editionRepo = EditionRepository();

  /// Crea una nueva participación con validaciones
  ///
  /// Valida:
  /// - Existencia de la feria
  /// - Existencia de la edición y pertinencia a la feria
  /// - Que el usuario no tenga ya una participación en esa edición
  Future<Result<Participation>> createParticipation(
      CreateParticipationRequest request) async {
    // Validar que la feria exista
    final fairResult = await _fairRepo.getById(request.fairId);
    if (fairResult.isError) {
      return Result.error('Feria no encontrada');
    }

    // Validar que la edición exista y pertenezca a la feria
    final editionResult = await _editionRepo.getById(request.editionId);
    if (editionResult.isError) {
      return Result.error('Edición no encontrada');
    }

// Validar que el usuario no tenga ya una participación en esa edición
    final hasDuplicate =
        await _hasUserParticipation(request.userId, request.editionId);
    if (hasDuplicate) {
      return Result.error(
          'El usuario ya tiene una participación en esta edición');
    }

    // Crear la participación
    final participation = Participation(
      id: '', // ID se asigna en el repositorio
      userId: request.userId,
      fairId: request.fairId,
      editionId: request.editionId,
      boothNumber: request.boothNumber?.trim(),
      participationCost: request.particpationCost,
      createdAt: DateTime.now(),
    );
    final result = await _participationRepo.add(participation);

    if (result.isError) {
      return Result.error('Error al crear la participación');
    }

    return Result.success(result.data!);
  }

  /// Obtiene una participación con todos los detalles
  Future<Result<ParticipationDetails>> getParticipationsDetails(
      String participationId) async {
    final participationResult =
        await _participationRepo.getById(participationId);
    if (participationResult.isError) {
      return Result.error('Participación no encontrada');
    }
    final participation = participationResult.data!;
    final fairResult = await _fairRepo.getById(participation.fairId);
    final editionResult = await _editionRepo.getById(participation.editionId);

    if (fairResult.isError || editionResult.isError) {
      return Result.error('Error al obtener detalles de feria o edición');
    }
    return Result.success(
      ParticipationDetails(
        participation: participation,
        fair: fairResult.data!,
        edition: editionResult.data!,
      ),
    );
  }

  /// Obtiene todas las participaciones de un usuario
  Future<Result<List<Participation>>> getUserParticipations(
      String userId) async {
    return await _participationRepo.getParticipationsByUserId(userId);
  }

  /// Obtiene los detalles completos de una participación (Feria + Edición)
  Future<Result<ParticipationDetails>> getParticipationDetails(
      String participationId) async {
    try {
      // 1.  Obtener la participación
      final partResult = await _participationRepo.getById(participationId);
      if (partResult.isError)
        return Result.error('Participación no encontrada');
      final participation = partResult.data!;

      // 2.  Obtener la feria relacionada
      final fairResult = await _fairRepo.getById(participation.fairId);
      if (fairResult.isError) return Result.error('Feria no encontrada');

      // 3.  Obtener la edición relacionada
      final editionResult = await _editionRepo.getById(participation.editionId);
      if (editionResult.isError) return Result.error('Edición no encontrada');

      // 4.  Devolver el combo (DTO)
      return Result.success(ParticipationDetails(
        participation: participation,
        fair: fairResult.data!,
        edition: editionResult.data!,
      ));
    } catch (e) {
      return Result.error('Error al obtener detalles de la participación: $e');
    }
  }

  /// Actualiza una participación existente
  Future<Result<Participation>> updateParticipation(
      Participation updateParticipation) async {
    return await _participationRepo.saveParticipation(updateParticipation);
  }

  /// Elimina una participación y todas sus subcolecciones
  ///
  /// TODO: Implementar eliminación en cascada de contactos, ventas y visitantes
  Future<Result<bool>> deleteParticipation(String participationId) async {
    return await _participationRepo.delete(participationId);
  }

  /// ====== MÉTODOS PARA SUBCOLECCIONES ======

  /// Agregar un contacto a una participación
  Future<Result<Contact>> addContact(
      String participationId, Contact contact) async {
    return await _participationRepo.addContact(participationId, contact);
  }

  /// Agregar una venta a una participación
  Future<Result<Sale>> addSale(String participationId, Sale sale) async {
    return await _participationRepo.addSale(participationId, sale);
  }

  /// Agregar un registro de visitante a una participación
  Future<Result<Visitor>> addVisitor(
      String participationId, Visitor visitor) async {
    return await _participationRepo.addVisitor(participationId, visitor);
  }

  /// Stream de una participación
  Stream<List<Contact>> streamContacts(String participationId) {
    return _participationRepo.streamContacts(participationId);
  }

  /// Srteam de ventas de una participación
  Stream<List<Sale>> streamSales(String participationId) {
    return _participationRepo.streamSales(participationId);
  }

  /// Stream de visitantes de una participación
  Stream<List<Visitor>> streamVisitors(String participationId) {
    return _participationRepo.streamVisitors(participationId);
  }

  /// ====== MÉTODOS ESTADÍSTICOS ======

  /// Calcula el total de ventas de una participación.
  Future<Result<double>> getTotalSales(String participationId) async {
    try {
      final sales = await _participationRepo.streamSales(participationId).first;
      final total = sales.fold<double>(0, (sum, sale) => sum + sale.amount);
      return Result.success(total);
    } catch (e) {
      return Result.error('Error al calcular el total de ventas: $e');
    }
  }

  /// Calcula el total de visitantes de una participación.
  Future<Result<int>> getTotalVisitors(String participationId) async {
    try {
      final visitors =
          await _participationRepo.streamVisitors(participationId).first;
      final total =
          visitors.fold<int>(0, (sum, visitor) => sum + visitor.count);
      return Result.success(total);
    } catch (e) {
      return Result.error('Error al calcular el total de visitantes: $e');
    }
  }

  /// Calcula el total de contactos de una participación.
  Future<Result<int>> getTotalContacts(String participationId) async {
    try {
      final contacts =
          await _participationRepo.streamContacts(participationId).first;
      return Result.success(contacts.length);
    } catch (e) {
      return Result.error('Error al calcular el total de contactos: $e');
    }
  }

  /// Calcula el ROI de una participación.
  Future<Result<double>> calculateRoi(String participationId) async {
    final participationResult =
        await _participationRepo.getById(participationId);
    if (participationResult.isError) {
      return Result.error('Participación no encontrada');
    }
    final participation = participationResult.data!;
    final totalSalesResult = await getTotalSales(participationId);

    if (totalSalesResult.isError) {
      return totalSalesResult;
    }

    final totalSales = totalSalesResult.data!;
    final cost = participation.participationCost;

    if (cost == 0) {
      return Result.success(totalSales > 0 ? 100 : 0.0);
    }

    final roi = ((totalSales - cost) / cost) * 100;
    return Result.success(roi);
  }

  /// Verifica si un usuario ya tiene una participación en una edición
  Future<bool> _hasUserParticipation(String userId, String editionId) async {
    final participationsResult =
        await _participationRepo.getParticipationsByUserId(userId);

    if (participationsResult.isError) return false;

    return participationsResult.data!.any((p) => p.editionId == editionId);
  }

  /// Stream de participaciones de un usuario
  Stream<List<Participation>> streamParticipations(String userId) {
    return _participationRepo.streamParticipationsByUserId(userId);
  }

  /// Obtiene todas las participaciones de un usuario con detalles completos

  Future<Result<List<ParticipationDetails>>> getUserParticipationsDetailed(
      String userId) async {
    try {
      final result = await _participationRepo.getParticipationsByUserId(userId);
      if (result.isError) {
        return Result.error(result.error!);
      }
      final List<ParticipationDetails> detailedList = [];

      for (var participation in result.data!) {
        final fairResult = await _fairRepo.getById(participation.fairId);
        final editionResult =
            await _editionRepo.getById(participation.editionId);

        if (fairResult.isSuccess && editionResult.isSuccess) {
          detailedList.add(ParticipationDetails(
            participation: participation,
            fair: fairResult.data!,
            edition: editionResult.data!,
          ));
        }
      }

      return Result.success(detailedList);
    } catch (e) {
      return Result.error('Error al procesar detalles de participaciones: $e');
    }
  }
}
