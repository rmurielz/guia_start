import 'package:flutter/material.dart';
import 'package:guia_start/models/participation_model.dart';
import 'package:guia_start/models/sale_model.dart';
import 'package:guia_start/models/contact_model.dart';
import 'package:guia_start/models/visitor_model.dart';
import 'package:guia_start/providers/app_state_provider.dart';
import 'package:guia_start/services/participation_service.dart';
import 'package:guia_start/screens/sales/sale_form_screen.dart';
import 'package:guia_start/screens/contacts/contact_form_screen.dart';
import 'package:guia_start/screens/visitors/visitor_form_screen.dart';
import 'package:provider/provider.dart';

class ParticipationDetailScreen extends StatefulWidget {
  final Participation participation;

  const ParticipationDetailScreen({super.key, required this.participation});

  @override
  State<ParticipationDetailScreen> createState() =>
      _ParticipationDetailScreenState();
}

class _ParticipationDetailScreenState extends State<ParticipationDetailScreen>
    with SingleTickerProviderStateMixin {
  final ParticipationService _participationService = ParticipationService();

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
    final detailResults = await _participationService
        .getParticipationsDetails(widget.participation.id);

    if (detailResults.isSuccess && mounted) {
      final details = detailResults.data!;
      context.read<AppStateProvider>().setActiveParticipation(
            participation: details.participation,
            fair: details.fair,
            edition: details.edition,
          );
      setState(() {
        _isLoadingDetails = false;
        _fairName = details.fair.name;
        _editionName = details.edition.name;
      });
    } else if (detailResults.isError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(detailResults.error ?? 'Error al cargar los detalles')),
      );
    }
  }

  Future<void> _loadStats() async {
    final salesResult =
        await _participationService.getTotalSales(widget.participation.id);
    final visitorsResult =
        await _participationService.getTotalVisitors(widget.participation.id);
    final contactsResult =
        await _participationService.getTotalContacts(widget.participation.id);
    final roiResult =
        await _participationService.calculateRoi(widget.participation.id);

    if (mounted) {
      setState(() {
        _totalSales = salesResult.isSuccess ? salesResult.data! : 0.0;
        _totalVisitors = visitorsResult.isSuccess ? visitorsResult.data! : 0;
        _totalContacts = contactsResult.isSuccess ? contactsResult.data! : 0;
        _roi = roiResult.isSuccess ? roiResult.data! : 0.0;
        _isLoadingStats = false;
      });
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.tertiary.withOpacity(0.2),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _fairName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.tertiary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _editionName,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.tertiary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (widget.participation.boothNumber != null)
                RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                          child: Icon(Icons.store,
                              size: 16, color: colorScheme.tertiary)),
                      TextSpan(
                        text: 'Stand ${widget.participation.boothNumber}',
                        style: TextStyle(
                            color: colorScheme.tertiary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                        child: Icon(Icons.attach_money,
                            size: 16, color: colorScheme.tertiary)),
                    TextSpan(
                      text:
                          ' Costo: ${widget.participation.participationCost.toStringAsFixed(0)}',
                      style:
                          TextStyle(color: colorScheme.tertiary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.spaceEvenly,
        children: [
          _buildStatCard('Ventas', '\$${_totalSales.toStringAsFixed(0)}',
              Icons.attach_money, colorScheme),
          _buildStatCard(
              'Contactos', '$_totalContacts', Icons.people, colorScheme),
          _buildStatCard(
              'Visitantes', '$_totalVisitors', Icons.groups, colorScheme),
          _buildStatCard('ROI', '${_roi.toStringAsFixed(2)}%',
              Icons.trending_up, colorScheme),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return SizedBox(
      width: 150,
      child: Column(
        children: [
          Icon(icon, size: 24, color: colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.tertiary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.tertiary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }


// ========= TABS =========

class _SalesTab extends StatelessWidget {
  final String participationId;
  final VoidCallback onSaleAdded;

  const _SalesTab({required this.participationId, required this.onSaleAdded});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final participationService = ParticipationService();

    return Scaffold(
      body: StreamBuilder<List<Sale>>(
        stream: participationService.streamSales(participationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
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
                    color: colorScheme.tertiary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay ventas registradas',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.tertiary.withOpacity(0.6),
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
                    '\$${sale.paymentMethod} • ${sale.products}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${sale.createdAt.day}/${sale.createdAt.month}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.tertiary.withOpacity(0.6),
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
}

// ========= TAB CONTACTOS =========

class _ContactsTab extends StatelessWidget {
  final String participationId;
  final VoidCallback onContactAdded;

  const _ContactsTab(
      {required this.participationId, required this.onContactAdded});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final participationService = ParticipationService();

    return Scaffold(
      body: StreamBuilder<List<Contact>>(
        stream: participationService.streamContacts(participationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
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
                    color: colorScheme.tertiary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay contactos registrados',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.tertiary.withOpacity(0.6),
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
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.secondary,
                    child: const Icon(Icons.person, color: Colors.black),
                  ),
                  title: Text('Contacto: ${contact.thirdPartyId}'),
                  subtitle: contact.notes != null
                      ? Text(
                          contact.notes!,
                        )
                      : null,
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
                builder: (context) =>
                    ContactFormScreen(participationId: participationId)),
          );
          onContactAdded();
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

// ========= TAB VISITANTES =========

class _VisitorsTab extends StatelessWidget {
  final String participationId;
  final VoidCallback onVisitorAdded;

  const _VisitorsTab(
      {required this.participationId, required this.onVisitorAdded});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final participationService = ParticipationService();

    return Scaffold(
      body: StreamBuilder<List<Visitor>>(
        stream: participationService.streamVisitors(participationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
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
                    color: colorScheme.tertiary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay visitantes registrados',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.tertiary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          final totalVisitors =
              visitors.fold<int>(0, (sum, visitor) => sum + visitor.count);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people, color: colorScheme.tertiary),
                    const SizedBox(width: 8),
                    Text(
                      'Total: $totalVisitors visitantes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: visitors.length,
                  itemBuilder: (context, index) {
                    final visitor = visitors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.secondary,
                          child: Text(
                            '${visitor.count}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        title: Text(
                          '${visitor.timestamp.day}/${visitor.timestamp.month}/${visitor.timestamp.year}',
                        ),
                        subtitle:
                            visitor.notes != null ? Text(visitor.notes!) : null,
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
}
