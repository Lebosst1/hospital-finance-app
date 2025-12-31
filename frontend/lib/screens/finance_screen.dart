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
  String? _explicationIA;
  String? _badgeFiabilite;

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

      // Appel analyse IA explicative globale
      String? explication;
      String? badge;
      try {
        final analyse = await ApiService.getAnalyseIAGlobale();
        explication = analyse['explication'] ?? null;
        badge = analyse['badge'] ?? null;
      } catch (_) {}

      setState(() {
        _services = services;
        _sejours = sejours;
        _explicationIA = explication;
        _badgeFiabilite = badge;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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

                        // ========= EXPLICATION IA =========
                        if (_explicationIA != null || _badgeFiabilite != null)
                          Card(
                            elevation: 2,
                            color: Colors.indigo.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_badgeFiabilite != null)
                                    Container(
                                      margin: const EdgeInsets.only(right: 16),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _badgeFiabilite == 'Prédiction fiable' ? Colors.green.shade100 : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _badgeFiabilite!,
                                        style: TextStyle(
                                          color: _badgeFiabilite == 'Prédiction fiable' ? Colors.green.shade800 : Colors.orange.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      _explicationIA ?? 'Aucune explication IA disponible.',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),
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
