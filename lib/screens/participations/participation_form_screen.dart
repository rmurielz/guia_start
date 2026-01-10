import 'package:flutter/material.dart';
import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/models/edition_model.dart';
import 'package:guia_start/models/participation_model.dart';
import 'package:guia_start/repositories/participation_repository.dart';
import 'package:guia_start/services/auth_service.dart';

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

class _ParticipationFormScreenState extends State<ParticipationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ParticipationRepository _participationRepo = ParticipationRepository();
  final AuthService _authService = AuthService();

  final TextEditingController _boothController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _boothController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _saveParticipation() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = _authService.getCurrentUser()?.uid;
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      final participation = Participation(
        id: '',
        userId: userId,
        fairId: widget.fair.id,
        fairName: widget.fair.name,
        editionId: widget.edition.id,
        editionName: widget.edition.name,
        boothNumber: _boothController.text.trim().isEmpty
            ? null
            : _boothController.text.trim(),
        participationCost: double.parse(_costController.text.trim()),
        createdAt: DateTime.now(),
      );

      final result = await _participationRepo.add(participation);

      if (result.isSuccess && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participación registrada')),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error $e')),
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
                color: colorScheme.primary.withOpacity(0.1),
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
                      color: colorScheme.tertiary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: colorScheme.tertiary.withOpacity(0.7),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.edition.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.tertiary.withOpacity(0.7),
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
                onPressed: _isSaving ? null : _saveParticipation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
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
