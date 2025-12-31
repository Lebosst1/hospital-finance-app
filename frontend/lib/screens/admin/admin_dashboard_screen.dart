
import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../services/api_service.dart';
import '../../models/analyse_ia.dart';
import '../../models/service_hospitalier.dart';

// ...existing code...

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _iaCriticalNotified = false;
  Map<String, dynamic>? _analyseIAGlobale;
  bool _loading = true;
  String? _error;
  List<ServiceHospitalier> _services = [];
  Map<int, AnalyseIA> _analyseParService = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final analyse = await ApiService.getAnalyseIAGlobale();
      final services = await ApiService.getServices();
      final Map<int, AnalyseIA> analyseServices = {};
      for (final s in services) {
        if (s.idService != null) {
          try {
            analyseServices[s.idService!] = await ApiService.getAnalyseIAService(s.idService!);
          } catch (_) {}
        }
      }
      setState(() {
        _analyseIAGlobale = analyse;
        _services = services;
        _analyseParService = analyseServices;
        _loading = false;
      });
      // Notification IA critique (snackbar)
      if (!_iaCriticalNotified) {
        final hasCritical = analyseServices.values.any((a) => a.niveauRisque.toLowerCase().contains('élevé') || a.niveauRisque.toLowerCase().contains('eleve'));
        if (hasCritical && mounted) {
          _iaCriticalNotified = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚠️ Alerte IA critique détectée sur au moins un service !'),
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Administrateur'),
        backgroundColor: Colors.indigo.shade400,
      ),
      drawer: AppDrawer(isAdmin: true, currentRoute: '/admin'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur IA : $_error'))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (_analyseIAGlobale != null) ...[
                      Card(
                        color: Colors.indigo.shade50,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, color: Colors.deepPurple, size: 28),
                                  const SizedBox(width: 10),
                                  Text('Résumé IA du jour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo.shade700)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(_analyseIAGlobale!['resume'] ?? 'Aucune synthèse IA disponible.', style: const TextStyle(fontSize: 15)),
                              if (_analyseIAGlobale!['conseil'] != null && (_analyseIAGlobale!['conseil'] as String).isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text('Conseil : ${_analyseIAGlobale!['conseil']}', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Text('Bienvenue, Administrateur', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 18),
                    if (_services.isNotEmpty) ...[
                      Card(
                        color: Colors.red.shade50,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.warning_amber, color: Colors.red, size: 28),
                                  const SizedBox(width: 10),
                                  Text('Alertes IA prioritaires', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red.shade700)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ..._services.map((s) {
                                final analyse = _analyseParService[s.idService ?? -1];
                                if (analyse == null || analyse.niveauRisque.isEmpty || analyse.niveauRisque == 'faible') return const SizedBox.shrink();
                                Color riskColor = Colors.orange;
                                String riskLabel = 'Risque';
                                if (analyse.niveauRisque.contains('élevé') || analyse.niveauRisque.contains('eleve')) {
                                  riskColor = Colors.red;
                                  riskLabel = '🔴 Risque élevé';
                                } else if (analyse.niveauRisque.contains('modéré') || analyse.niveauRisque.contains('modere')) {
                                  riskColor = Colors.orange;
                                  riskLabel = '🟠 Risque modéré';
                                }
                                return ListTile(
                                  leading: Icon(Icons.warning, color: riskColor),
                                  title: Text('${s.nomService} - $riskLabel', style: TextStyle(color: riskColor, fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (analyse.resume.isNotEmpty) Text(analyse.resume),
                                      if (analyse.conseil.isNotEmpty) Text('Conseil : ${analyse.conseil}', style: const TextStyle(fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              if (_services.where((s) {
                                final analyse = _analyseParService[s.idService ?? -1];
                                return analyse != null && analyse.niveauRisque.isNotEmpty && analyse.niveauRisque != 'faible';
                              }).isEmpty)
                                const Text('Aucune alerte IA prioritaire détectée.', style: TextStyle(fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: _services.map<Widget>((s) {
                        final analyse = _analyseParService[s.idService ?? -1];
                        String riskLabel = 'Risque inconnu';
                        Color riskColor = Colors.grey;
                        if (analyse != null && analyse.niveauRisque.isNotEmpty) {
                          if (analyse.niveauRisque.contains('faible')) {
                            riskLabel = '🟢 Risque faible';
                            riskColor = Colors.green;
                          } else if (analyse.niveauRisque.contains('modéré') || analyse.niveauRisque.contains('modere')) {
                            riskLabel = '🟠 Risque modéré';
                            riskColor = Colors.orange;
                          } else if (analyse.niveauRisque.contains('élevé') || analyse.niveauRisque.contains('eleve')) {
                            riskLabel = '🔴 Risque élevé';
                            riskColor = Colors.red;
                          }
                        }
                        return _adminCard(context, Icons.business, s.nomService, riskLabel, riskColor, '/admin/services', analyse != null ? analyse.conseil : null);
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: Colors.indigo.withOpacity(0.12)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.indigo.shade400),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Astuce : Utilisez le menu latéral pour accéder rapidement à toutes les fonctionnalités administratives.',
                              style: TextStyle(fontSize: 15, color: Colors.indigo.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _adminCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    String route,
    String? conseilIA,

  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: color),
              ),
              if (conseilIA != null && conseilIA.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  "IA : $conseilIA",
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

