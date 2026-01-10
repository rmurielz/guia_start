import 'package:flutter/material.dart';
import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/models/edition_model.dart';
import 'package:guia_start/repositories/edition_repository.dart';
import 'package:guia_start/services/auth_service.dart';

class EditionFormScreen extends StatefulWidget {
  final Fair fair;

  const EditionFormScreen({super.key, required this.fair});

  @override
  State<EditionFormScreen> createState() => _EditionFormScreenState();
}

class _EditionFormScreenState extends State<EditionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final EditionRepository _editionRepo = EditionRepository();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _initDate;
  DateTime? _endDate;
  String _status = 'planning';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isInitDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isInitDate) {
          _initDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveEdition() async {
    if (!_formKey.currentState!.validate()) return;

    if (_initDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_initDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The end date must be after the start date'),
        ),
      );
      return;
    }
    final userId = _authService.getCurrentUser()?.uid;
    if (userId == null) return;

    setState(() => _isSaving = true);

    try {
      final edition = Edition(
        id: '',
        fairId: widget.fair.id,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        initDate: _initDate!,
        endDate: _endDate!,
        createdBy: userId,
        createdAt: DateTime.now(),
        status: _status,
      );

      final result = await _editionRepo.add(edition);

      if (result.isError) {
        throw Exception(result.error);
      }
      if (mounted) {
        Navigator.pop(context, result.data);
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text(
          'Crear edición',
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
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Feria ${widget.fair.name}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              style: TextStyle(color: colorScheme.tertiary),
              decoration: const InputDecoration(
                labelText: 'Nombre de la edición',
                prefixIcon: Icon(Icons.event),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Campo Requerido'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              style: TextStyle(color: colorScheme.tertiary),
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Campo Requerido'
                  : null,
            ),
            const SizedBox(height: 24),
            Text(
              'Fechas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Fecha de inicio'),
              subtitle: Text(_formatDate(_initDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: colorScheme.tertiary.withOpacity(0.3),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Fecha de finalización'),
              subtitle: Text(_formatDate(_endDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: colorScheme.tertiary.withOpacity(0.3),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Estado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.info_outline),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'planning',
                  child: Text('Planificación'),
                ),
                DropdownMenuItem(
                  value: 'active',
                  child: Text('Activa'),
                ),
                DropdownMenuItem(
                  value: 'finished',
                  child: Text('Finalizada'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveEdition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'Crear Edición',
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
