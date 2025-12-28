// Nombre de colecciones en Firestore
class FirestoreCollections {
  static const String users = 'users';
  static const String fairs = 'fairs';
  static const String editions = 'editions';
  static const String participations = 'participations';
  static const String thirdParties = 'thirdParties';

// Subcolecciones
  static const String contacts = 'contacts';
  static const String sales = 'sales';
  static const String visitors = 'visitors';

  /// Construir path para subcolección
  static String participationContacts(String participacionId) =>
      '$participations/$participacionId/$contacts';

  static String participationSales(String participacionId) =>
      '$participations/$participacionId/$sales';

  static String participationVisitors(String participacionId) =>
      '$participations/$participacionId/$visitors';
}
