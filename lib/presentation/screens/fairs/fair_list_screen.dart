import 'package:flutter/material.dart';
import 'package:guia_start/core/di/injection_container.dart';
import 'package:guia_start/domain/usecases/participation/get_user_participations_usecase.dart';
import 'package:guia_start/presentation/screens/participations/participation_detail_screen.dart';
import 'package:guia_start/presentation/screens/fairs/fair_search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FairListScreen extends StatefulWidget {
  const FairListScreen({super.key});

  @override
  State<FairListScreen> createState() => _FairListScreenState();
}

class _FairListScreenState extends State<FairListScreen> {
  Future<List<ParticipationDetails>> _loadParticipations() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final result = await di.getUserParticipationsUseCase(
      GetUserParticipationsParams(userId: currentUser.uid),
    );

    if (result.isSuccess) {
      return result.data!;
    } else {
      throw Exception(result.error ?? 'Error al cargar participaciones');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text(
          'Mis Participaciones',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FairSearchScreen()),
            ),
            tooltip: 'Buscar ferias',
          ),
        ],
      ),
      body: FutureBuilder<List<ParticipationDetails>>(
        future: _loadParticipations(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar participaciones',
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.tertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                    ),
                    child: const Text(
                      'Reintentar',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          }

          // Success
          final participations = snapshot.data ?? [];

          if (participations.isEmpty) {
            return _buildEmptyState(context, colorScheme);
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: participations.length,
              itemBuilder: (context, index) {
                return _buildParticipationCard(
                  context,
                  colorScheme,
                  participations[index],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticipationCard(
    BuildContext context,
    ColorScheme colorScheme,
    ParticipationDetails details,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParticipationDetailScreen(
                participation: details.participation,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título: Nombre de la feria
              Text(
                details.fair.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),

              // Edición
              Row(
                children: [
                  const Icon(Icons.event, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    details.edition.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Costo
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '\$${details.participation.participationCost.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Estado de la edición
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(details.edition.status, colorScheme),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  details.edition.status.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(dynamic status, ColorScheme colorScheme) {
    final statusName = status.toString().split('.').last;
    switch (statusName) {
      case 'planning':
        return Colors.blue.shade200;
      case 'active':
        return Colors.green.shade200;
      case 'finished':
        return Colors.grey.shade300;
      case 'cancelled':
        return Colors.red.shade200;
      default:
        return colorScheme.surface;
    }
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: colorScheme.tertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes participaciones registradas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: colorScheme.tertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Busca ferias y participa para verlas aquí',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.tertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FairSearchScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.search, color: Colors.black),
                label: const Text(
                  'Buscar Ferias',
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
