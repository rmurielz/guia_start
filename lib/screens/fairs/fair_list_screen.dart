import 'package:flutter/material.dart';
import 'package:guia_start/services/participation_service.dart';
import 'package:guia_start/services/auth_service.dart';
import 'package:guia_start/screens/participations/participation_detail_screen.dart';
import 'package:guia_start/screens/fairs/fair_search_screen.dart';
import 'package:guia_start/utils/result.dart';

class FairListScreen extends StatefulWidget {
  const FairListScreen({super.key});

  @override
  State<FairListScreen> createState() => _FairListScreenState();
}

class _FairListScreenState extends State<FairListScreen> {
  final ParticipationService _participationService = ParticipationService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userId = _authService.getCurrentUser()?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text(
          'Mis participaciones',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FairSearchScreen()),
            ),
          ),
        ],
      ),
      body: userId == null
          ? const Center(
              child: Text('Inicia sesión para ver tus participaciones.'))
          : FutureBuilder<Result<List<ParticipationDetails>>>(
              future:
                  _participationService.getUserParticipationsDetailed(userId),
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error
                if (snapshot.hasData && snapshot.data!.isSuccess) {
                  final ListDetails = snapshot.data!.data!;

                  if (ListDetails.isEmpty) {
                    return _buildEmpyState(context);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ListDetails.length,
                    itemBuilder: (context, index) {
                      return _buildParticipationCard(
                          context, ListDetails[index]);
                    },
                  );
                }

                return Center(
                  child: Text(
                      'Error: ${snapshot.data?.error ?? "Error desconocido"}'),
                );
              },
            ),
    );
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
              Text(
                details.edition.name,
                style: TextStyle(
                    color: colorScheme.primary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14),
                  const SizedBox(width: 4),
                  Text(details.edition.location,
                      style: const TextStyle(fontSize: 13)),
                  if (details.participation.participationCost != null) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.attach_money, size: 14),
                    const SizedBox(width: 4),
                    Text('Costo: $details.participation.participationCost}'),
                  ],
                ],
              ),
            ],
          ),
        ),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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

  Widget _buildEmpyState(BuildContext context) {
    // Sin Datos
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Aún No tienes ferias registradas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FairSearchScreen()),
            ),
            icon: const Icon(Icons.search),
            label: const Text('Buscar Ferias'),
          ),
        ],
      ),
    );
  }
}
