import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guia_start/models/participation_model.dart';
import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/models/edition_model.dart';
import 'package:guia_start/models/third_party_model.dart';
import 'package:guia_start/models/user_profile_model.dart';

class AppStateProvider extends ChangeNotifier {
  // ========= ESTADO =========

  // Participación actualmente seleccionada
  Participation? _activeParticipation;

  // Datos relacionados a la participación activa
  Fair? _activeFair;
  Edition? _activeEdition;
  UserProfile? _userProfile;
  ThirdParty? _activeOrganizer;

  // ========= GETTERS =========

  Participation? get activeParticipation => _activeParticipation;
  Fair? get activeFair => _activeFair;
  UserProfile? get userProfile => _userProfile;
  Edition? get activeEdition => _activeEdition;
  ThirdParty? get activeOrganizer => _activeOrganizer;

  // Verificar si hay una participación activa
  bool get hasActiveParticipation => _activeParticipation != null;
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  // ========= SETTERS =========

  // Establecer la participación activa y sus datos relacionados
  void setActiveParticipation({
    required Participation? participation,
    Fair? fair,
    Edition? edition,
    ThirdParty? organizer,
  }) {
    _activeParticipation = participation;
    _activeFair = fair;
    _activeEdition = edition;
    _activeOrganizer = organizer;
    notifyListeners();
  }

  // Limpiar la participación activa
  void clearActiveParticipation() {
    _activeParticipation = null;
    _activeFair = null;
    _activeEdition = null;
    _activeOrganizer = null;
    _userProfile = null;
    notifyListeners();
  }

  // Limpiar todo el estado (Útil al cargar la sesión)
  void clearAll() {
    _activeParticipation = null;
    _activeFair = null;
    _activeEdition = null;
    _activeOrganizer = null;
    _userProfile = null;
    notifyListeners();
  }

  // ========= MÉTODOS HELPER =========

  void setUserProfile(UserProfile? profile) {
    _userProfile = profile;
    notifyListeners();
  }

  // Obtener el nombre completo de la feria activa
  String? getActiveFairDisplayName() {
    if (_activeFair == null || _activeEdition == null) return null;
    return '${_activeFair!.name} - ${_activeEdition!.name}';
  }

  // Obtener ubicación de la edición activa
  String? getActiveEditionLocation() {
    return _activeEdition?.location;
  }
}
