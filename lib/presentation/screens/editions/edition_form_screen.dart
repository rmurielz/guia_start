import 'package:flutter/material.dart';
import 'package:guia_start/domain/entities/fair.dart';
import 'package:guia_start/domain/entities/edition.dart';
import 'package:guia_start/core/di/injection_container.dart';
import 'package:guia_start/core/utils/async_processor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guia_start/domain/usecases/edition/create_edition_usecase.dart';

class EditionFormScreen extends StatefulWidget {
  final Fair fair;

  const EditionFormScreen({super.key, required this.fair});

  @override
  State<EditionFormScreen> createState() => _EditionFormScreenState();
}

class _EditionFormScreenState extends State<EditionFormScreen>
    with AsyncProcessor {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _initDate;
  DateTime? _endDate;
  String _status = 'planning';

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
          content: Text('Please select dates'),
        ),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
      }
      return;
    }

    final edition = Edition(
      id: 'id',
      fairId: widget.fair.id,
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      initDate: _initDate!,
      endDate: _endDate!,
      createdBy: currentUser.uid,
      createdAt: DateTime.now(),
      status: EditionStatus.values.firstWhere((e) => e.name == _status),
    );

    await executeOperation(
      operation: di.createEditionUseCase(CreateEditionParams(edition: edition)),
      successMessage: 'Edition created succesfully!',
      onSuccess: () => Navigator.pop(context),
    );
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
                  color: colorScheme.tertiary,
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
                  color: colorScheme.tertiary,
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
                onPressed: isProcessing ? null : _saveEdition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isProcessing
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
