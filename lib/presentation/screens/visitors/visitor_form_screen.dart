import 'package:flutter/material.dart';
import 'package:guia_start/core/di/injection_container.dart';
import 'package:guia_start/domain/usecases/participation/add_visitor_usecase.dart';

class VisitorFormScreen extends StatefulWidget {
  final String participationId;

  const VisitorFormScreen({super.key, required this.participationId});

  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _countController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    _countController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveVisitor() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSaving = true);

    try {
      final result = await di.addVisitorUseCase(
        AddVisitorParams(
          participationId: widget.participationId,
          count: int.parse(_countController.text.trim()),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ),
      );

      if (!mounted) return;

      if (result.isSuccess) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Visitor saved succesfully!'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ${result.error}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving visitor: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
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
            'Visitor Form',
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
              // Contador de visitantes
              TextFormField(
                controller: _countController,
                style: TextStyle(color: colorScheme.tertiary),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Visitors',
                  prefixIcon: Icon(Icons.people),
                  hintText: '0',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the number of visitors.';
                  }
                  final count = int.tryParse(value);
                  if (count == null || count <= 0) {
                    return 'Please enter a valid non-negative number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notas
              TextFormField(
                controller: _notesController,
                style: TextStyle(color: colorScheme.tertiary),
                maxLines: 3,
                decoration: const InputDecoration(
                  label: Text('Notes (optional)'),
                  prefixIcon: Icon(Icons.notes),
                  hintText: 'Additional information about the visitors',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Botón Guardar
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveVisitor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Save Visitor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              )
            ],
          ),
        ));
  }
}
