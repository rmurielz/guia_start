import 'package:flutter/material.dart';
import 'package:guia_start/domain/entities/fair.dart';
import 'package:guia_start/core/di/injection_container.dart';
import 'package:guia_start/presentation/screens/fairs/fair_form_screen.dart';
import 'package:guia_start/presentation/screens/editions/edition_list_screen.dart';
import 'package:guia_start/domain/usecases/fair/get_fair_with_organizer_usecase.dart';

class FairSearchScreen extends StatefulWidget {
  const FairSearchScreen({super.key});

  @override
  State<FairSearchScreen> createState() => _FairSearchScreenState();
}

class _FairSearchScreenState extends State<FairSearchScreen> {
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

    final result = await di.searchFairsWithOrganizerUseCase(query);
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
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Buscar Ferias',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: colorScheme.tertiary),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre de feria...',
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => _searchFairs(),
            ),
          ),

          // Resultados
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _hasSearched && _searchResults.isEmpty
                    ? const Center(
                        child: Text('No se encontraron ferias'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final fairWithOrganizer = _searchResults[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              title: Text(
                                fairWithOrganizer.fair.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    fairWithOrganizer.fair.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.business,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        fairWithOrganizer.organizer.name,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _selectFair(fairWithOrganizer.fair),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        onPressed: _createNewFair,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
