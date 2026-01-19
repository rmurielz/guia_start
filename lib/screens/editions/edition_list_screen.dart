import 'package:flutter/material.dart';
import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/models/edition_model.dart';
import 'package:guia_start/repositories/edition_repository.dart';
import 'package:guia_start/screens/editions/edition_form_screen.dart';
import 'package:guia_start/screens/participations/participation_form_screen.dart';

class EditionListScreen extends StatefulWidget {
  final Fair fair;

  const EditionListScreen({super.key, required this.fair});

  @override
  State<EditionListScreen> createState() => _EditionListScreenState();
}

class _EditionListScreenState extends State<EditionListScreen> {
  final EditionRepository _editionRepo = EditionRepository();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          widget.fair.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<Edition>>(
        stream: _editionRepo.streamEditionsByFairId(widget.fair.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final editions = snapshot.data ?? [];

          if (editions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note,
                    size: 64,
                    color: colorScheme.tertiary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay ediciones registradas',
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.tertiary.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Presiona + para crear una edición',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.tertiary.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: editions.length,
            itemBuilder: (context, index) {
              final edition = editions[index];
              return _EditionCard(
                edition: edition,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParticipationFormScreen(
                          fair: widget.fair, edition: edition),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditionFormScreen(fair: widget.fair),
            ),
          );

          if (!context.mounted) return;

          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Edidión $result creada')),
            );
          }
        },
        backgroundColor: colorScheme.primary,
        icon: const Icon(
          Icons.add,
          color: Colors.black,
        ),
        label: const Text(
          'Nueva edición',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _EditionCard extends StatelessWidget {
  final Edition edition;
  final VoidCallback onTap;

  const _EditionCard({
    required this.edition,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                edition.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: colorScheme.tertiary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    edition.location,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.tertiary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colorScheme.tertiary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: edition.isActive
                          ? Colors.green.withOpacity(0.2)
                          : colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      edition.isActive
                          ? 'Activa'
                          : edition.isFinished
                              ? 'Finalizada'
                              : 'Planificación',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: edition.isActive
                            ? Colors.green.shade700
                            : edition.isFinished
                                ? Colors.grey.shade700
                                : colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
