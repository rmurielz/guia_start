import 'package:flutter/material.dart';
import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/models/third_party_model.dart';
import 'package:guia_start/repositories/fair_repository.dart';
import 'package:guia_start/repositories/third_party_repository.dart';
import 'package:guia_start/services/auth_service.dart';
import 'package:guia_start/utils/async_processor.dart';
import 'package:guia_start/utils/result.dart';
import 'package:guia_start/widgets/searchable_dropdown.dart';
import 'package:guia_start/utils/validators.dart';

class FairFormScreen extends StatefulWidget {
  const FairFormScreen({super.key});

  @override
  State<FairFormScreen> createState() => _FairFormScreenState();
}

class _FairFormScreenState extends State<FairFormScreen> with AsyncProcessor {
  final _formKey = GlobalKey<FormState>();
  final FairRepository _fairRepo = FairRepository();
  final ThirdPartyRepository _thirdPartyRepo = ThirdPartyRepository();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  ThirdParty? _selectedOrganizer;
  bool _isRecurring = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _executeAsync({
    required Future<void> Function() operation,
    required String loadingFlag, // Searching o Saving
    String? successMessage,
    String? errorMessage,
  }) async {
    setState(() {
      if (loadingFlag == 'saving') {
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
          if (loadingFlag == 'saving') {
            _isSaving = false;
          }
        });
      }
    }
  }

  Future<void> _saveFair() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOrganizer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un organizador')),
      );
      return;
    }

    final userId = _authService.getCurrentUser()?.uid;
    if (userId == null) return;

    await executeOperation<Fair>(
      operation: _createFair(userId),
      successMessage: 'Feria creada exitosamente',
      onSuccess: () {
        Navigator.of(context).pop();
      },
    );

    Future<Result<Fair>> _createFair(String userId) async {
      final newFair = Fair(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        organizerId: _selectedOrganizer!.id,
        isRecurring: _isRecurring,
        createdBy: userId,
        createdAt: DateTime.now(),
      );

      final result = await _fairRepo.add(newFair);

      if (result.isError) {
        return Result.error(result.error!);
      }

      return Result.success(newFair.copyWith(id: result.data));
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
              validator: Validators.compose([
                Validators.required('Campo requerido'),
                Validators.minLength(3, 'Mínimo 3 caracteres'),
                Validators.maxLength(50, 'Máximo 50 caracteres'),
              ]),
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
              validator: Validators.compose([
                Validators.required('La descripción es obligatoria'),
                Validators.minLength(10, 'Mínimo 10 caracteres'),
              ]),
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
            SearchableDropdown<ThirdParty>(
              labelText: 'Buscar Organizador',
              prefixIcon: Icons.business,
              selectedItem: _selectedOrganizer,
              onSearch: (query) async {
                final results =
                    await _thirdPartyRepo.searchThirdPartiesByName(query);
                return results
                    .where((tp) => tp.type == ThirdPartyType.organizer)
                    .toList();
              },
              onSelected: (organizer) {
                setState(() {
                  _selectedOrganizer = organizer;
                });
              },
              onCreate: (name) async {
                final userId = _authService.getCurrentUser()?.uid;
                if (userId == null) throw Exception('Usuario no autenticado');

                final organizer = ThirdParty(
                  id: '',
                  name: name,
                  type: ThirdPartyType.organizer,
                  createdBy: userId,
                  createdAt: DateTime.now(),
                );
                final result = await _thirdPartyRepo.add(organizer);

                if (result.isError) {
                  throw Exception(result.error);
                }
                return organizer.copyWith(id: result.data);
              },
              itemBuilder: (organizer) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organizer.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  if (organizer.contactEmail != null)
                    Text(
                      organizer.contactEmail!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    )
                ],
              ),
              displayText: (organizer) => organizer.name,
              emptyMessage: 'No se encontraron organizadores',
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
                onPressed: isProcessing ? null : _saveFair,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isProcessing
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
