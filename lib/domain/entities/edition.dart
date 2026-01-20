import 'package:guia_start/domain/entities/entity.dart';

class Edition extends Entity {
  @override
  final String id;
  final String fairId;
  final String name;
  final String location;
  final DateTime initDate;
  final DateTime endDate;
  final String createdBy;
  final DateTime createdAt;
  final EditionStatus status;

  Edition({
    required this.id,
    required this.fairId,
    required this.name,
    required this.location,
    required this.initDate,
    required this.endDate,
    required this.createdBy,
    required this.createdAt,
    required this.status,
  });

  @override
  Edition copyWith({
    String? id,
    String? fairId,
    String? name,
    String? location,
    DateTime? initDate,
    DateTime? endDate,
    String? createdBy,
    DateTime? createdAt,
    EditionStatus? status,
  }) {
    return Edition(
        id: id ?? this.id,
        fairId: fairId ?? this.fairId,
        name: name ?? this.name,
        location: location ?? this.name,
        initDate: initDate ?? this.initDate,
        endDate: endDate ?? this.endDate,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        status: status ?? this.status);
  }

  // Business logic
  bool get isPlanning => status == EditionStatus.planning;
  bool get isActive => status == EditionStatus.active;
  bool get isFinished => status == EditionStatus.finished;
  bool get isCancelled => status == EditionStatus.cancelled;

  bool get canEdit => isPlanning;
  bool get canRegisterSales => isActive;
  bool get canExport => isFinished;

  /// Valida que las fechas sean coherentes
  bool hasValidDates() {
    return endDate.isAfter(initDate);
  }

  /// Verifica si las fechas se superponen con otra edición
  bool overlaps(Edition other) {
    final startsInRange =
        initDate.isAfter(other.initDate) && initDate.isBefore(other.endDate);
    final endsInRange =
        endDate.isAfter(other.initDate) && endDate.isBefore(other.endDate);
    final engulfsOther =
        initDate.isBefore(other.initDate) && endDate.isAfter(other.endDate);

    return startsInRange || endsInRange || engulfsOther;
  }

  @override
  String toString() {
    return 'Edition(id: $id, name $name, status ${status.name})';
  }
}

enum EditionStatus {
  planning,
  active,
  finished,
  cancelled;

  String get displayName {
    switch (this) {
      case EditionStatus.planning:
        return 'Planificación';
      case EditionStatus.active:
        return 'Activa';
      case EditionStatus.finished:
        return 'Finalizada';
      case EditionStatus.cancelled:
        return 'Cancelada';
    }
  }
}
