import 'package:flutter/material.dart';
import 'package:guia_start/models/contact_model.dart';
import 'package:guia_start/models/third_party_model.dart';
import 'package:guia_start/repositories/participation_repository.dart';
import 'package:guia_start/repositories/third_party_repository.dart';

class ContactFormScreen extends StatefulWidget {
  final String participationId;

  const ContactFormScreen({super.key, required this.participationId});

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ParticipationRepository _participationRepo = ParticipationRepository();
  final ThirdPartyRepository _thirdPartyRepo = ThirdPartyRepository();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  ThirdParty? _selectedThirdParty;
  List<ThirdParty> _searchResults = [];
  bool _isSearching = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _searchThirdParties() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);

    try {
      final results = await _thirdPartyRepo.searchThirdPartiesByName(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching third parties: $e')),
        );
      }
    }
  }

  void _selectThirdParty(ThirdParty thirdParty) {
    setState(() {
      _selectedThirdParty = thirdParty;
      _searchResults = [];
      _searchController.text = thirdParty.name;
    });
  }

  Future<void> _saveContact() async {
    if (_selectedThirdParty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a third party')),
      );
      return;
    }
    setState(() => _isSaving = true);

    try {
      final contact = Contact(
        id: '',
        thirdPartyId: _selectedThirdParty!.id,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      final contactId = await _participationRepo.addContact(
        widget.participationId,
        contact,
      );

      if (contactId != null && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact saved successfully')),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving contact: $e')),
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
          'Add Contact',
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
            // Buscador de Terceros
            TextFormField(
              controller: _searchController,
              style: TextStyle(color: colorScheme.tertiary),
              decoration: InputDecoration(
                labelText: 'Search Third Party',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _selectedThirdParty != null ? Icon(Icons.search) : null,
              ),
              onChanged: (value) {
                if (_selectedThirdParty != null) {
                  setState(() => _selectedThirdParty = null);
                }
                _searchThirdParties();
              },
            ),
            // Indicador de búsqueda
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            // Resultados de búsqueda
            if (_searchResults.isNotEmpty)
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
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final thirdParty = _searchResults[index];
                    return ListTile(
                      dense: true,
                      title: Text(thirdParty.name),
                      subtitle: thirdParty.contactEmail != null
                          ? Text(thirdParty.contactEmail!)
                          : null,
                      trailing: Text(
                        thirdParty.type.toString().split('.').last,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.tertiary.withOpacity(0.6),
                        ),
                      ),
                      onTap: () => _selectThirdParty(thirdParty),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),
            // Campo de notas
            TextFormField(
              controller: _notesController,
              style: TextStyle(color: colorScheme.tertiary),
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // Botón de guardar
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveContact,
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
                        'Save Contact',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
