// Interfaz para todas las entidades del dominio que tienen identidad única.

abstract class Entity {
  // Identificador único de la entidad.
  String get id;

  Entity copyWith({String? id});

  bool get isNew => id.isEmpty;
  bool get isExisting => id.isNotEmpty;
  bool isSameAs(Entity other) => id == other.id;
  bool isDifferentFrom(Entity other) => id != other.id;
}
