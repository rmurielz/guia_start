import 'package:flutter/material.dart';
import 'package:guia_start/repositories/fair_repository.dart';
import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/screens/fairs/fair_form_screen.dart';

class FairSearchScreen extends StatefulWidget {
  const FairSearchScreen({super.key});

  @override
  State<FairSearchScreen> createState() => _FairSearchScreenState();
}

class _FairSearchScreenState extends State<FairSearchScreen> {
  final FairRepository _fairRepo = FairRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Fair> _searchResults = [];
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

    try {
      final results = await _fairRepo.searchFairByName(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar: $e')),
        );
      }
    }
  }

  void _selectFair(Fair fair) {
    Navigator.pop(context, fair);
  }

  Future<void> _createNewFair() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FairFormScreen()),
    );

    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text(
          'Buscar Feria',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: colorScheme.tertiary),
              decoration: InputDecoration(
                hintText: 'Nombre de la feria',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {}); // Para actualizar el botón clear
              },
              onSubmitted: (_) => _searchFairs(),
            ),
          ),

          // Botón buscar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSearching ? null : _searchFairs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.search, color: Colors.black),
                label: Text(
                  _isSearching ? 'Buscando...' : 'Buscar',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Resultados de búsqueda
          Expanded(
            child: _isSearching
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  )
                : _hasSearched && _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: colorScheme.tertiary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron ferias',
                              style: TextStyle(
                                fontSize: 18,
                                color: colorScheme.tertiary.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _createNewFair,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.secondary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.add, color: Colors.black),
                              label: const Text(
                                'Crear nueva feria',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Text(
                              'Busca una feria existente / Crea una nueva',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.tertiary.withOpacity(0.5),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final fair = _searchResults[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(
                                    fair.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.tertiary,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(fair.description),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Organizador: ${fair.organizerName}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.tertiary
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: colorScheme.primary.withOpacity(0.7),
                                    size: 16,
                                  ),
                                  onTap: () => _selectFair(fair),
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
          child: OutlinedButton.icon(
            onPressed: _createNewFair,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.primary, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
            label: Text(
              'Crear nueva feria',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
