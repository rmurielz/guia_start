import 'package:flutter/material.dart';
import 'package:guia_start/domain/entities/fair.dart';
import 'package:guia_start/domain/entities/edition.dart';
import 'package:guia_start/domain/entities/participation.dart';
import 'package:guia_start/core/di/injection_container.dart';
import 'package:guia_start/core/utils/async_processor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guia_start/domain/usecases/participation/create_participation_usecase.dart';

class ParticipationFormScreen extends StatefulWidget {
  final Fair fair;
  final Edition edition;

  const ParticipationFormScreen({
    super.key,
    required this.fair,
    required this.edition,
  });

  @override
  State<ParticipationFormScreen> createState() =>
      _ParticipationFormScreenState();
}

class _ParticipationFormScreenState extends State<ParticipationFormScreen>
    with AsyncProcessor {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _boothController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  @override
  void dispose() {
    _boothController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _saveParticipation() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
      }
      return;
    }

    final participation = Participation(
      id: '',
      userId: currentUser.uid,
      fairId: widget.fair.id,
      editionId: widget.edition.id,
      boothNumber: _boothController.text.trim().isEmpty
          ? null
          : _boothController.text.trim(),
      participationCost: double.parse(_costController.text.trim()),
      createdAt: DateTime.now(),
    );

    await executeOperation(
      operation: di.createParticipationUseCase(
          CreateParticipationParams(participation: participation)),
      successMessage: 'Participation created succesfully!',
      onSuccess: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text(
          'Registrar Participación',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.fair.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.edition.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: colorScheme.tertiary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.edition.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _boothController,
              style: TextStyle(
                color: colorScheme.tertiary,
              ),
              decoration: const InputDecoration(
                labelText: 'Número de Stand',
                prefixIcon: Icon(Icons.store),
                hintText: 'Ej A-15',
              ),
            ),
            const SizedBox(height: 16),

            // Costo de participación
            TextFormField(
              controller: _costController,
              style: TextStyle(
                color: colorScheme.tertiary,
              ),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Costo de participación',
                prefixIcon: Icon(Icons.attach_money),
                hintText: '0',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo Requerido';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un valor numérico válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Botón Guardar
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isProcessing ? null : _saveParticipation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isProcessing
                    ? const CircularProgressIndicator(
                        color: Colors.black,
                      )
                    : const Text(
                        'Registrar Participación',
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
