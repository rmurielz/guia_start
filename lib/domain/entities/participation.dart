import 'package:guia_start/domain/entities/entity.dart  ';

class Participation extends Entity {
  @override
  final String id;
  final String userId;
  final String fairId;
  final String editionId;
  final String? boothNumber;
  final double participationCost;
  final DateTime createdAt;

  Participation({
    required this.id,
    required this.userId,
    required this.fairId,
    required this.editionId,
    this.boothNumber,
    required this.participationCost,
    required this.createdAt,
  });

  @override
  Participation copyWith({
    String? id,
    String? userId,
    String? fairId,
    String? editionId,
    String? boothNumber,
    double? participationCost,
    DateTime? createdAt,
  }) {
    return Participation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fairId: fairId ?? this.fairId,
      editionId: editionId ?? this.editionId,
      boothNumber: boothNumber ?? this.boothNumber,
      participationCost: participationCost ?? this.participationCost,
      createdAt: createdAt ?? this.createdAt,
    );
  }

// Bussines logic
  bool get hasBoothAssigned => boothNumber != null && boothNumber!.isNotEmpty;
  bool get isFree => participationCost == 0.0;

  /// Calcula ROI basado en ventas totales
  double calculateROI(double totalSales) {
    if (participationCost == 0) {
      return totalSales > 0 ? 100.0 : 0.0;
    }
    return ((totalSales - participationCost) / participationCost) * 100;
  }

  @override
  String toString() {
    return 'Participation(id: $id, fairId: $fairId, cost: $participationCost)';
  }
}
