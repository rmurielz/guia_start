import 'package:flutter/material.dart';
import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/models/third_party_model.dart';
import 'package:guia_start/repositories/fair_repository.dart';
import 'package:guia_start/repositories/third_party_repository.dart';
import 'package:guia_start/services/auth_service.dart';

class FairFormScreen extends StatefulWidget {
  const FairFormScreen({super.key});

  @override
  State<FairFormScreen> createState() => _FairFormScreenState();
}

class _FairFormScreenState extends State<FairFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FairRepository _fairRepo = FairRepository();
  final ThirdPartyRepository _thirdPartyRepo = ThirdPartyRepository();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _organizerSearchController =
      TextEditingController();

  ThirdParty? _selectedOrganizer;
  List<ThirdParty> _organizerResults = [];
  bool _isRecurring = false;
  bool _isSearchingOrganizer = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _organizerSearchController.dispose();
    super.dispose();
  }

  Future<void> _executeAsync({
    required Future<void> Function() operation,
    required String loadingFlag, // Searching o Saving
    String? successMessage,
    String? errorMessage,
  }) async {
    setState(() {
      if (loadingFlag == 'searching') {
        _isSearchingOrganizer = true;
      } else if (loadingFlag == 'saving') {
        _isSaving = true;
      }
    });

    try {
      await operation();
      if (successMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage ?? 'Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (loadingFlag == 'searching') {
            _isSearchingOrganizer = false;
          } else if (loadingFlag == 'saving') {
            _isSaving = false;
          }
        });
      }
    }
  }

  Future<void> _searchOrganizers() async {
    final query = _organizerSearchController.text.trim();

    if (query.isEmpty) return;

    await _executeAsync(
      operation: () async {
        final results = await _thirdPartyRepo.searchThirdPartiesByName(query);
        final organizers =
            results.where((tp) => tp.type == ThirdPartyType.organizer).toList();

        setState(() {
          _organizerResults = organizers;
        });
      },
      loadingFlag: 'searching',
      errorMessage: 'Error al buscar organizadores',
    );
  }

  void _selectOrganizer(ThirdParty organizer) {
    setState(() {
      _selectedOrganizer = organizer;
      _organizerSearchController.text = organizer.name;
      _organizerResults = [];
    });
  }

  Future<void> _createNewOrganizer() async {
    final name = _organizerSearchController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese el nombre del organizador')),
      );
      return;
    }

    final userId = _authService.getCurrentUser()?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }
    await _executeAsync(
      operation: () async {
        final newOrganizer = ThirdParty(
          id: '',
          name: name,
          type: ThirdPartyType.organizer,
          createdBy: userId,
          createdAt: DateTime.now(),
        );

        final organizerId = await _thirdPartyRepo.addThirdParty(newOrganizer);

        if (organizerId == null || organizerId.isEmpty) {
          throw Exception('Error al crear el organizador');
        }

        setState(() {
          _selectedOrganizer = newOrganizer.copyWith(id: organizerId);
          _organizerResults = [];
        });
      },
      loadingFlag: 'saving',
      successMessage: 'Organizador creado exitosamente',
      errorMessage: 'Error al crear el organizador',
    );
  }

  Future<void> _saveFair() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedOrganizer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona o crea un organizador')),
      );
      return;
    }

    final userId = _authService.getCurrentUser()?.uid;
    if (userId == null) return;

    setState(() => _isSaving = true);

    try {
      final fair = Fair(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        organizerId: _selectedOrganizer!.id,
        organizerName: _selectedOrganizer!.name,
        createdBy: userId,
        createdAt: DateTime.now(),
        isRecurring: _isRecurring,
      );
      final fairId = await _fairRepo.addFair(fair);

      if (fairId != null && mounted) {
        final createdFair = fair.copyWith(id: fairId);
        Navigator.pop(context, createdFair);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text(
          'Crear Feria',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Nombre de Feria
            TextFormField(
              controller: _nameController,
              style: TextStyle(color: colorScheme.tertiary),
              decoration: const InputDecoration(
                  labelText: 'Nombre de Feria', prefixIcon: Icon(Icons.event)),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Campo requerido'
                  : null,
            ),
            const SizedBox(height: 16.0),

            // Descripción
            TextFormField(
              controller: _descriptionController,
              style: TextStyle(color: colorScheme.tertiary),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Campo requerido'
                  : null,
            ),
            const SizedBox(height: 24.0),

            // Sección organizador
            Text(
              'Organizador',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.tertiary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8.0),
            // Buscador organizador
            TextFormField(
              controller: _organizerSearchController,
              style: TextStyle(color: colorScheme.tertiary),
              decoration: InputDecoration(
                labelText: 'Buscar organizador',
                prefixIcon: const Icon(Icons.business),
                suffixIcon: _selectedOrganizer != null
                    ? Icon(Icons.check_circle, color: colorScheme.primary)
                    : null,
              ),
              onChanged: (value) {
                if (_selectedOrganizer != null) {
                  setState(() => _selectedOrganizer = null);
                }
                _searchOrganizers();
              },
            ),

            // Resultados búsqueda organizador
            if (_isSearchingOrganizer)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (_organizerResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: colorScheme.tertiary.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _organizerResults.length,
                  itemBuilder: (context, index) {
                    final organizer = _organizerResults[index];
                    return ListTile(
                        dense: true,
                        title: Text(organizer.name),
                        subtitle: organizer.contactEmail != null
                            ? Text(organizer.contactEmail!)
                            : null,
                        onTap: () => _selectOrganizer(organizer));
                  },
                ),
              ),

            // Botón Crear Organizador
            if (_organizerSearchController.text.isNotEmpty &&
                _selectedOrganizer == null &&
                _organizerResults.isEmpty &&
                !_isSearchingOrganizer)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: _createNewOrganizer,
                  icon: const Icon(Icons.add),
                  label: Text(
                    'Crear Organizador "${_organizerSearchController.text}"',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

            const SizedBox(height: 24.0),

            // Checkbox Recurrente
            SwitchListTile(
              value: _isRecurring,
              onChanged: (value) => setState(() => _isRecurring = value),
              title: const Text('¿Es una feria recurrente?'),
              subtitle: const Text('Mensual, anual....'),
              activeThumbColor: colorScheme.primary,
            ),

            const SizedBox(height: 32.0),

// Botón Guardar
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveFair,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'Crear Feria',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
