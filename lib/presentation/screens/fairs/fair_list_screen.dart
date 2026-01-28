import 'package:flutter/material.dart';
import 'package:guia_start/core/di/injection_container.dart';
import 'package:guia_start/presentation/screens/participations/participation_detail_screen.dart';
import 'package:guia_start/presentation/screens/fairs/fair_search_screen.dart';
import 'package:guia_start/domain/usecases/participation/get_user_participations_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FairListScreen extends StatefulWidget {
  const FairListScreen({super.key});

  @override
  State<FairListScreen> createState() => _FairListScreenState();
}

class _FairListScreenState extends State<FairListScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text(
          'Mis participaciones',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FairSearchScreen()),
            ),
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(
              child: Text('Inicia sesión para ver tus participaciones.'))
          : FutureBuilder<List<ParticipationDetails>>(
              future: _loadParticipations(currentUser.uid),
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                // Success
                if (snapshot.hasData) {
                  final listDetails = snapshot.data!;

                  if (listDetails.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listDetails.length,
                    itemBuilder: (context, index) {
                      return _buildParticipationCard(
                          context, listDetails[index]);
                    },
                  );
                }

                return const Center(child: Text('No data'));
              },
            ),
    );
  }

  Future<List<ParticipationDetails>> _loadParticipations(String userId) async {
    final result = await di.getUserParticipationsUseCase(
      GetUserParticipationsParams(userId: userId),
    );

    if (result.isSuccess) {
      return result.data!;
    } else {
      throw Exception(result.error ?? 'Error loading participations');
    }
  }

  Widget _buildParticipationCard(
      BuildContext context, ParticipationDetails details) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        // Título: Nombre de la feria (desde el DTO)
        title: Text(
          details.fair.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
// Subtítulo: Nombre de la edición y Costo (desde el DTO)
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.event, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(details.edition.name),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                      '\$${details.participation.participationCost.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(details.edition.status, colorScheme),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  details.edition.status.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing:
            const Icon(Icons.chevron_right, color: Colors.black, size: 28),
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
      ),
    );
  }

  Color _getStatusColor(dynamic status, ColorScheme colorScheme) {
    final statusName = status.toString().split('.').last;
    switch (statusName) {
      case 'planning':
        return Colors.blue.shade100;
      case 'active':
        return Colors.green.shade100;
      case 'finished':
        return Colors.grey.shade300;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return colorScheme.surface;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No tienes participaciones registradas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Busca ferias y participa para verlas aquí',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
