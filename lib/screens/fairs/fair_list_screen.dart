import 'package:flutter/material.dart';
import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/screens/editions/edition_list_screen.dart';
import 'package:guia_start/screens/fairs/fair_form_screen.dart';
import 'package:guia_start/screens/fairs/fair_search_screen.dart';
import 'package:guia_start/screens/participations/participation_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:guia_start/providers/app_state_provider.dart';
import 'package:guia_start/repositories/participation_repository.dart';
import 'package:guia_start/models/participation_model.dart';
import 'package:guia_start/services/auth_service.dart';

class FairListScreen extends StatefulWidget {
  const FairListScreen({super.key});

  @override
  State<FairListScreen> createState() => _FairListScreenState();
}

class _FairListScreenState extends State<FairListScreen> {
  final ParticipationRepository _participationRepo = ParticipationRepository();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userId = _authService.getCurrentUser()?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text(
          'Mis ferias',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
            ),
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Provider.of<AppStateProvider>(context, listen: false)
                    .clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión cerrada')),
                );
              }
            },
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: Text('Error: Usuario no autenticado'))
          : StreamBuilder<List<Participation>>(
              stream: _participationRepo.streamParticipationsByUserId(userId),
              builder: (context, snapshot) {
                // Loading

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                // Sin Datos
                final participations = snapshot.data ?? [];
                if (participations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: colorScheme.tertiary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes ferias registradas',
                          style: TextStyle(
                            fontSize: 18,
                            color: colorScheme.tertiary.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Presiona + para agregar tu primera feria',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.tertiary.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Lista de participantes
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: participations.length,
                  itemBuilder: (context, index) {
                    final participation = participations[index];
                    return _ParticipationCard(
                      participation: participation,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParticipationDetailScreen(
                              participation: participation,
                            ),
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
          // Primero buscar feria existente o decidir crear una nueva
          final searchResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FairSearchScreen(),
            ),
          );

          if (searchResult == null) return;

          Fair? selectedFair;

          // Si el usuario seleccionó "Crear nueva"
          if (searchResult == 'create_new') {
            final createdFair = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FairFormScreen(),
              ),
            );
            selectedFair = createdFair is Fair ? createdFair : null;
          } else if (searchResult is Fair) {
            selectedFair = searchResult;
          }

          if (selectedFair != null && mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditionListScreen(fair: selectedFair!),
              ),
            );
          }
        },
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Nueva Participación',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

//Widget para cada participación
class _ParticipationCard extends StatelessWidget {
  final Participation participation;
  final VoidCallback onTap;

  const _ParticipationCard({
    required this.participation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              // Título placeholder (necesitamos fair name)
              Text(
                'Feria: ${participation.fairName}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 8),

              // Stand
              if (participation.boothNumber != null)
                Row(
                  children: [
                    Icon(
                      Icons.store,
                      size: 16,
                      color: colorScheme.tertiary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Stand: ${participation.boothNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.tertiary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),

              // Costo
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: colorScheme.tertiary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${participation.participationCost.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: colorScheme.tertiary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fecha
              Text(
                'Registrado: ${_formatDate(participation.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.tertiary.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
