import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guia_start/core/di/injection_container.dart';
import 'package:guia_start/domain/usecases/dashboard/get_dashboard_stats_usecase.dart';
import 'package:guia_start/presentation/screens/fairs/fair_list_screen.dart';
import 'package:guia_start/presentation/screens/fairs/fair_search_screen.dart';
import 'package:guia_start/presentation/screens/fairs/fair_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    final result = await di.getDashboardStatsUseCase(currentUser.uid);

    if (mounted) {
      setState(() {
        _stats = result.isSuccess ? result.data : null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        title: const Text(
          'GUIA Start',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadStats,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con stats
              _buildStatsSection(colorScheme),

              const SizedBox(height: 24),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acciones rápidas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(colorScheme),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Empty state o sugerencias
              if (_stats != null && !_stats!.hasParticipations)
                _buildEmptyState(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.black),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Activas',
                  '${_stats?.activeParticipations ?? 0}',
                  Icons.event_available,
                  Colors.green.shade700,
                ),
                _buildStatCard(
                  'Próximas',
                  '${_stats?.upcomingParticipations ?? 0}',
                  Icons.event_note,
                  Colors.blue.shade700,
                ),
                _buildStatCard(
                  'Total',
                  '${_stats?.totalParticipations ?? 0}',
                  Icons.event,
                  Colors.orange.shade700,
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildActionCard(
          colorScheme,
          title: 'Mis Participaciones',
          subtitle: 'Ver y gestionar tus ferias',
          icon: Icons.event,
          iconColor: Colors.green.shade700,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FairListScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          colorScheme,
          title: 'Buscar Ferias',
          subtitle: 'Encuentra nuevas oportunidades',
          icon: Icons.search,
          iconColor: Colors.blue.shade700,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FairSearchScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          colorScheme,
          title: 'Crear Feria',
          subtitle: 'Solo para organizadores',
          icon: Icons.add_business,
          iconColor: Colors.orange.shade700,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FairFormScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    ColorScheme colorScheme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 80,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '¡Comienza tu primera participación!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.tertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Busca ferias que se ajusten a tu negocio y participa para hacer crecer tus ventas',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.tertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
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
    );
  }
}
