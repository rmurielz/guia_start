/// Interfaz para todas las entidades del dominio
abstract class Entity {
  String get id;

  Entity copyWith({String? id});

  bool get isNew => id.isEmpty;
  bool get isExisting => id.isNotEmpty;
  bool isSameAs(Entity other) => id == other.id;
  bool isDifferentFrome(Entity other) => id != other.id;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Entity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
