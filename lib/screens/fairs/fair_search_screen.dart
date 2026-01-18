import 'package:flutter/material.dart';
import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/services/fair_service.dart';
import 'package:guia_start/screens/fairs/fair_form_screen.dart';
import 'package:guia_start/screens/editions/edition_list_screen.dart';
import 'package:guia_start/utils/result.dart';

class FairSearchScreen extends StatefulWidget {
  const FairSearchScreen({super.key});

  @override
  State<FairSearchScreen> createState() => _FairSearchScreenState();
}

class _FairSearchScreenState extends State<FairSearchScreen> {
  final FairService _fairService = FairService();
  final TextEditingController _searchController = TextEditingController();

  List<FairWithOrganizer> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchFairs() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    // Llamamos al método del servicio que armamos

    final result = await _fairService.searchFairWithOrganizer(query);
    if (mounted) {
      setState(() {
        _isSearching = false;
        _searchResults = result.isSuccess ? result.data! : [];
      });
    }
  }

  void _selectFair(Fair fair) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditionListScreen(fair: fair),
      ),
    );
  }

  void _createNewFair() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FairFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buscar Ferias',
        ),
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nombre de la feria',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchFairs();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _searchFairs(),
            ),
          ),
          // Resultados de búsqueda
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(item.fair.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle:
                                  Text('Organiza: ${item.organizer.name}}'),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _selectFair(item.fair),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _createNewFair,
            icon: const Icon(Icons.add),
            label: const Text('Crear nueva feria'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (!_hasSearched) {
      return const Center(
          child: Text('Escribe el nombre de una feria para comernzar'));
    }
    return const Center(child: Text('No se encontraron resultados'));
  }
}
