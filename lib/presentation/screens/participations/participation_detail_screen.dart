import 'package:flutter/material.dart';
import 'package:guia_start/domain/entities/participation.dart';
import 'package:guia_start/domain/entities/sale.dart';
import 'package:guia_start/domain/entities/contact.dart';
import 'package:guia_start/domain/entities/visitor.dart';
import 'package:guia_start/domain/usecases/participation/get_participations_stats_usecase.dart';
import 'package:guia_start/presentation/providers/app_state_provider.dart';
import 'package:guia_start/presentation/screens/sales/sale_form_screen.dart';
import 'package:guia_start/presentation/screens/contacts/contact_form_screen.dart';
import 'package:guia_start/presentation/screens/visitors/visitor_form_screen.dart';
import 'package:guia_start/core/di/injection_container.dart';
import 'package:provider/provider.dart';
import 'package:guia_start/domain/usecases/edition/get_editions_by_fair_usecase.dart';

class ParticipationDetailScreen extends StatefulWidget {
  final Participation participation;

  const ParticipationDetailScreen({super.key, required this.participation});

  @override
  State<ParticipationDetailScreen> createState() =>
      _ParticipationDetailScreenState();
}

class _ParticipationDetailScreenState extends State<ParticipationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingStats = true;
  bool _isLoadingDetails = true;
  double _totalSales = 0.0;
  int _totalVisitors = 0;
  int _totalContacts = 0;
  double _roi = 0.0;

  String _fairName = 'Cargando...';
  String _editionName = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDetails();
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    try {
      // Obtener fair
      final fairResult = await di.getFairUseCase(widget.participation.fairId);
      if (fairResult.isError) {
        throw Exception(fairResult.error);
      }

      // Obtener editions de la fair
      final editionsResult = await di.getEditionsByFairUseCase(
        GetEditionsByFairParams(fairId: widget.participation.fairId),
      );
      if (editionsResult.isError) {
        throw Exception(editionsResult.error);
      }

      // Buscar la edition específica
      final edition = editionsResult.data!.firstWhere(
        (e) => e.id == widget.participation.editionId,
        orElse: () => throw Exception('Edition not found'),
      );

      if (mounted) {
        final fair = fairResult.data!;

        context.read<AppStateProvider>().setActiveParticipation(
              participation: widget.participation,
              fair: fair,
              edition: edition,
            );
        setState(() {
          _isLoadingDetails = false;
          _fairName = fair.name;
          _editionName = edition.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar los detalles: $e')),
        );
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      final statsResult = await di.getParticipationsStatsUseCase(
        GetStatsParams(widget.participation.id),
      );

      if (statsResult.isSuccess && mounted) {
        final stats = statsResult.data!;
        setState(() {
          _totalSales = stats.totalSales;
          _totalVisitors = stats.visitorsCount;
          _totalContacts = stats.contactsCount;
          _roi = stats.roi;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isLoadingDetails) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          title: const Text(
            'Detalle de Participación',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Center(
            child: CircularProgressIndicator(color: colorScheme.primary)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text(
          'Detalle de Participación',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Ventas'),
            Tab(text: 'Contactos'),
            Tab(text: 'Visitantes'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildHeader(colorScheme),
          _buildStatSection(colorScheme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SalesTab(
                  participationId: widget.participation.id,
                  onSaleAdded: _loadStats,
                ),
                _ContactsTab(
                  participationId: widget.participation.id,
                  onContactAdded: _loadStats,
                ),
                _VisitorsTab(
                  participationId: widget.participation.id,
                  onVisitorAdded: _loadStats,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _fairName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _editionName,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          if (widget.participation.boothNumber != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.store, size: 16, color: Colors.black),
                const SizedBox(width: 4),
                Text(
                  'Stand: ${widget.participation.boothNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatSection(ColorScheme colorScheme) {
    if (_isLoadingStats) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            colorScheme,
            'Ventas',
            '\$${_totalSales.toStringAsFixed(2)}',
            Icons.attach_money,
          ),
          _buildStatCard(
            colorScheme,
            'Visitantes',
            _totalVisitors.toString(),
            Icons.people,
          ),
          _buildStatCard(
            colorScheme,
            'Contactos',
            _totalContacts.toString(),
            Icons.contacts,
          ),
          _buildStatCard(
            colorScheme,
            'ROI',
            '${_roi.toStringAsFixed(1)}%',
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ColorScheme colorScheme,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}

// ========= TABS =========

class _SalesTab extends StatelessWidget {
  final String participationId;
  final VoidCallback onSaleAdded;

  const _SalesTab({required this.participationId, required this.onSaleAdded});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FutureBuilder<List<Sale>>(
        future: _loadSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final sales = snapshot.data ?? [];

          if (sales.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay ventas registradas',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary,
                    child: const Icon(Icons.attach_money, color: Colors.black),
                  ),
                  title: Text('\$${sale.amount.toStringAsFixed(2)}'),
                  subtitle: Text(
                    '${sale.paymentMethod} • ${sale.products}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${sale.createdAt.day}/${sale.createdAt.month}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.tertiary,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SaleFormScreen(
                participationId: participationId,
              ),
            ),
          );
          onSaleAdded();
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Future<List<Sale>> _loadSales() async {
    final result = await di.participationRepository.getSales(participationId);
    if (result.isSuccess) {
      return result.data!;
    } else {
      throw Exception(result.error ?? 'Error loading sales');
    }
  }
}

class _ContactsTab extends StatelessWidget {
  final String participationId;
  final VoidCallback onContactAdded;

  const _ContactsTab(
      {required this.participationId, required this.onContactAdded});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FutureBuilder<List<Contact>>(
        future: _loadContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final contacts = snapshot.data ?? [];

          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contacts_outlined,
                    size: 64,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay contactos registrados',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return FutureBuilder(
                future: di.thirdPartyRepository.getById(contact.thirdPartyId),
                builder: (context, thirdPartySnapshot) {
                  if (thirdPartySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Card(
                      child: ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text('Cargando...'),
                      ),
                    );
                  }

                  final thirdPartyName = thirdPartySnapshot.hasData &&
                          thirdPartySnapshot.data!.isSuccess
                      ? thirdPartySnapshot.data!.data!.name
                      : 'Desconocido';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primary,
                        child: const Icon(Icons.person, color: Colors.black),
                      ),
                      title: Text(thirdPartyName),
                      subtitle: contact.notes != null
                          ? Text(
                              contact.notes!,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: Text(
                        '${contact.createdAt.day}/${contact.createdAt.month}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactFormScreen(
                participationId: participationId,
              ),
            ),
          );
          onContactAdded();
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Future<List<Contact>> _loadContacts() async {
    final result =
        await di.participationRepository.getContacts(participationId);
    if (result.isSuccess) {
      return result.data!;
    } else {
      throw Exception(result.error ?? 'Error loading contacts');
    }
  }
}

class _VisitorsTab extends StatelessWidget {
  final String participationId;
  final VoidCallback onVisitorAdded;

  const _VisitorsTab(
      {required this.participationId, required this.onVisitorAdded});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FutureBuilder<List<Visitor>>(
        future: _loadVisitors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final visitors = snapshot.data ?? [];

          if (visitors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay visitantes registrados',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Calcular total de visitantes
          final totalCount = visitors.fold<int>(
            0,
            (sum, visitor) => sum + visitor.count,
          );

          return Column(
            children: [
              // Total header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: colorScheme.primary,
                child: Text(
                  'Total de visitantes: $totalCount',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Lista
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: visitors.length,
                  itemBuilder: (context, index) {
                    final visitor = visitors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primary,
                          child: const Icon(Icons.people, color: Colors.black),
                        ),
                        title: Text('${visitor.count} visitantes'),
                        subtitle: visitor.notes != null
                            ? Text(
                                visitor.notes!,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: Text(
                          '${visitor.timestamp.day}/${visitor.timestamp.month}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.tertiary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VisitorFormScreen(
                participationId: participationId,
              ),
            ),
          );
          onVisitorAdded();
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Future<List<Visitor>> _loadVisitors() async {
    final result =
        await di.participationRepository.getVisitors(participationId);
    if (result.isSuccess) {
      return result.data!;
    } else {
      throw Exception(result.error ?? 'Error loading visitors');
    }
  }
}
