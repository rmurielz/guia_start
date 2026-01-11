import 'package:flutter/material.dart';
import 'package:guia_start/models/participation_model.dart';
import 'package:guia_start/models/fair_model.dart';
import 'package:guia_start/models/edition_model.dart';
import 'package:guia_start/models/sale_model.dart';
import 'package:guia_start/models/contact_model.dart';
import 'package:guia_start/models/visitor_model.dart';
import 'package:guia_start/repositories/participation_repository.dart';
import 'package:guia_start/repositories/fair_repository.dart';
import 'package:guia_start/repositories/edition_repository.dart';
import 'package:guia_start/screens/sales/sale_form_screen.dart';
import 'package:guia_start/screens/contacts/contact_form_screen.dart';
import 'package:guia_start/screens/visitors/visitor_form_screen.dart';

class ParticipationDetailScreen extends StatefulWidget {
  final Participation participation;

  const ParticipationDetailScreen({super.key, required this.participation});

  @override
  State<ParticipationDetailScreen> createState() =>
      _ParticipationDetailScreenState();
}

class _ParticipationDetailScreenState extends State<ParticipationDetailScreen>
    with SingleTickerProviderStateMixin {
  final FairRepository _fairRepo = FairRepository();
  final EditionRepository _editionRepo = EditionRepository();

  late TabController _tabController;
  Fair? _fair;
  Edition? _edition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final fairResult = await _fairRepo.getById(widget.participation.fairId);
      final editionResult =
          await _editionRepo.getById(widget.participation.editionId);

      if (fairResult.isError || editionResult.isError) {
        throw Exception('Error al cargar los datos');
      }

      setState(() {
        _fair = fairResult.data;
        _edition = editionResult.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            )
          : Column(
              children: [
                _buildHeader(colorScheme),

                // Tabs content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _SalesTab(participationId: widget.participation.id),
                      _ContactsTab(participationId: widget.participation.id),
                      _VisitorsTab(participationId: widget.participation.id),
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
            _fair?.name ?? 'Cargando...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _edition?.name ?? '',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.tertiary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (widget.participation.boothNumber != null) ...[
                Icon(
                  Icons.store,
                  size: 16,
                  color: colorScheme.tertiary.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text('Stand: ${widget.participation.boothNumber}',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.tertiary.withOpacity(0.7),
                    )),
                const SizedBox(width: 16),
              ],
              Icon(
                Icons.attach_money,
                size: 16,
                color: colorScheme.tertiary.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'Costo: \$${widget.participation.participationCost.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.tertiary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ========= TAB VENTAS =========

class _SalesTab extends StatelessWidget {
  final String participationId;

  const _SalesTab({required this.participationId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final participationRepo = ParticipationRepository();

    return Scaffold(
      body: StreamBuilder<List<Sale>>(
        stream: participationRepo.streamSales(participationId),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SaleFormScreen(
                participationId: participationId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

// ========= TAB CONTACTOS =========

class _ContactsTab extends StatelessWidget {
  final String participationId;

  const _ContactsTab({required this.participationId});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final participationRepo = ParticipationRepository();

    return Scaffold(
      body: StreamBuilder<List<Contact>>(
        stream: participationRepo.streamContacts(participationId),
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
                  title: Text('Contato: ${contact.thirdPartyId}'),
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactFormScreen(
                  participationId: participationId,
                ),
              ),
            );
          }),
    );
  }
}

// ========= TAB VISITANTES =========

class _VisitorsTab extends StatelessWidget {
  final String participationId;

  const _VisitorsTab({required this.participationId});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final participationRepo = ParticipationRepository();

    return Scaffold(
      body: StreamBuilder<List<Visitor>>(
        stream: participationRepo.streamVisitors(participationId),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VisitorFormScreen(
                participationId: participationId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
