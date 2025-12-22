import 'package:flutter/material.dart';
import '../models/service_hospitalier.dart';
import '../models/sejour.dart';
import '../services/api_service.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  bool _isLoading = false;
  List<ServiceHospitalier> _services = [];
  List<Sejour> _sejours = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ==========================
  //   CHARGER DONNÉES
  // ==========================
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // On charge services + séjours
      final services = await ApiService.getServices();
      final sejours = await ApiService.getSejours();

      setState(() {
        _services = services;
        _sejours = sejours;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement données financières : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================
  //   CALCULS GLOBAUX
  // ==========================

  double get _totalBudgetMensuel =>
      _services.map((s) => s.budgetMensuel ?? 0).fold(0.0, (a, b) => a + b);

  double get _totalBudgetAnnuel =>
      _services.map((s) => s.budgetAnnuel ?? 0).fold(0.0, (a, b) => a + b);

  double get _totalCoutReel =>
      _sejours.map((sj) => sj.cout ?? 0).fold(0.0, (a, b) => a + b);

  double _coutReelPourService(ServiceHospitalier service) {
    if (service.idService == null) return 0.0;

    return _sejours
        .where((sj) => sj.idService == service.idService)
        .map((sj) => sj.cout ?? 0)
        .fold(0.0, (a, b) => a + b);
  }

  // ==========================
  //   BUILD
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Synthèse financière'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/previsions'),
            icon: const Icon(Icons.trending_up, color: Colors.white),
            label: const Text(
              'Prévisions',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/alertes'),
            icon: const Icon(Icons.warning, color: Colors.white),
            label: const Text(
              'Alertes',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (_services.isEmpty && _sejours.isEmpty)
                  ? const Center(
                      child: Text('Aucune donnée financière disponible.'),
                    )
                  : ListView(
                      children: [
                        // ========= KPIs GLOBAUX =========
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildKpiCard(
                              title: 'Budget mensuel total',
                              value: '${_totalBudgetMensuel.toStringAsFixed(0)} DH',
                              icon: Icons.calendar_view_month,
                            ),
                            _buildKpiCard(
                              title: 'Budget annuel total',
                              value: '${_totalBudgetAnnuel.toStringAsFixed(0)} DH',
                              icon: Icons.calendar_today,
                            ),
                            _buildKpiCard(
                              title: 'Coût réel total séjours',
                              value: '${_totalCoutReel.toStringAsFixed(0)} DH',
                              icon: Icons.payments,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ========= TABLEAU PAR SERVICE =========
                        const Text(
                          'Détail par service',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Card(
                          elevation: 2,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Service')),
                                DataColumn(label: Text('Budget mensuel')),
                                DataColumn(label: Text('Coût réel séjours')),
                                DataColumn(label: Text('Écart')),
                                DataColumn(label: Text('Statut')),
                              ],
                              rows: _services.map((s) {
                                final budget = s.budgetMensuel ?? 0;
                                final coutReel = _coutReelPourService(s);
                                final ecart = budget - coutReel;
                                final bool depassement = coutReel > budget && budget > 0;

                                Color statutColor;
                                String statutText;

                                if (budget == 0 && coutReel == 0) {
                                  statutText = 'Aucune donnée';
                                  statutColor = Colors.grey;
                                } else if (depassement) {
                                  statutText = 'Dépassement';
                                  statutColor = Colors.red;
                                } else {
                                  statutText = 'Sous contrôle';
                                  statutColor = Colors.green;
                                }

                                return DataRow(
                                  cells: [
                                    DataCell(Text(s.nomService)),
                                    DataCell(
                                      Text('${budget.toStringAsFixed(0)} DH'),
                                    ),
                                    DataCell(
                                      Text('${coutReel.toStringAsFixed(0)} DH'),
                                    ),
                                    DataCell(
                                      Text(
                                        '${ecart.toStringAsFixed(0)} DH',
                                        style: TextStyle(
                                          color: ecart < 0 ? Colors.red : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: statutColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            statutText,
                                            style: TextStyle(
                                              color: statutColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ========= EXPLICATION / LÉGENDE =========
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Interprétation :',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '• "Budget mensuel" : allocation prévue pour le service.\n'
                                  '• "Coût réel séjours" : somme des coûts des séjours rattachés au service.\n'
                                  '• "Écart" = Budget mensuel - Coût réel.\n'
                                  '   → négatif = dépassement de budget.\n'
                                  '• "Dépassement" : le coût réel dépasse le budget.\n'
                                  '• "Sous contrôle" : le coût réel reste en dessous du budget.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.indigo),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
