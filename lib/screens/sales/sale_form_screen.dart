import 'package:flutter/material.dart';
import 'package:guia_start/models/sale_model.dart';
import 'package:guia_start/repositories/participation_repository.dart';

class SaleFormScreen extends StatefulWidget {
  final String participationId;

  const SaleFormScreen({super.key, required this.participationId});
  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ParticipationRepository _participationRepo = ParticipationRepository();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _productsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _paymentMethod = 'cash';
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _productsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveSale() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final sale = Sale(
          id: '',
          amount: double.parse(_amountController.text.trim()),
          paymentMethod: _paymentMethod,
          products: _productsController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: DateTime.now());
      final saleId =
          await _participationRepo.addSale(widget.participationId, sale);

      if (saleId != null && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale saved successfully')),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving sale: $e')),
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
          'New Sale',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
//            Monto
            TextFormField(
              controller: _amountController,
              style: TextStyle(color: colorScheme.tertiary),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
                hintText: '0',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an amount';
                }

                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Métdodo de pago
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                prefixIcon: Icon(Icons.payment),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'cash',
                  child: Text('Cash'),
                ),
                DropdownMenuItem(
                  value: 'credit_card',
                  child: Text('Credit Card'),
                ),
                DropdownMenuItem(
                  value: 'debit_card',
                  child: Text('Debit Card'),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Text('Other'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _paymentMethod = value);
                }
              },
            ),

            const SizedBox(height: 16),

// Productos

            TextFormField(
              controller: _productsController,
              style: TextStyle(color: colorScheme.tertiary),
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Products',
                prefixIcon: Icon(Icons.shopping_bag),
                hintText: 'List of products sold',
                alignLabelWithHint: true,
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter the products sold'
                  : null,
            ),
            const SizedBox(height: 16),

// Notas
            TextFormField(
              controller: _notesController,
              style: TextStyle(color: colorScheme.tertiary),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

// Botón guardar
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSale,
                style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'Save Sale',
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
