import 'package:flutter/material.dart';
import 'package:guia_start/models/third_party_model.dart';
import 'package:guia_start/repositories/third_party_repository.dart';
import 'package:guia_start/services/auth_service.dart';
import 'package:guia_start/services/fair_service.dart';
import 'package:guia_start/utils/async_processor.dart';
import 'package:guia_start/widgets/searchable_dropdown.dart';
import 'package:guia_start/utils/validators.dart';

class FairFormScreen extends StatefulWidget {
  const FairFormScreen({super.key});

  @override
  State<FairFormScreen> createState() => _FairFormScreenState();
}

class _FairFormScreenState extends State<FairFormScreen> with AsyncProcessor {
  final _formKey = GlobalKey<FormState>();
  final FairService _fairService = FairService();
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

  Future<void> _saveFair() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedOrganizer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un organizador')),
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

    final request = CreateFairRequest(
      name: _nameController.text,
      description: _descriptionController.text,
      organizerId: _selectedOrganizer!.id,
      isRecurring: _isRecurring,
      createdBy: userId,
    );

    await executeOperation(
      operation: _fairService.createFair(request),
      successMessage: 'Feria creada exitosamente',
      onSuccess: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text(
          'Crear una nueva feria',
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de Feria',
                prefixIcon: Icon(Icons.event),
              ),
              validator: Validators.compose([
                Validators.required('Campo requerido'),
                Validators.minLength(3, 'Mínimo 3 caracteres'),
                Validators.maxLength(50, 'Máximo 50 caracteres'),
              ]),
            ),
            const SizedBox(height: 16.0),
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
            Text(
              'Organizador',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.tertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
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
                return result.data!;
              },
              itemBuilder: (organizer) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organizer.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
            SwitchListTile(
              value: _isRecurring,
              onChanged: (value) => setState(() => _isRecurring = value),
              title: const Text('Es una Feria recurrente?'),
              subtitle: const Text('Mensual, Anual...'),
              activeThumbColor: colorScheme.primary,
            ),
            const SizedBox(height: 32.0),
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
