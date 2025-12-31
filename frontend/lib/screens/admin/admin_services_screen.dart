import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../services/api_service.dart';
import '../../models/service_hospitalier.dart';
import '../../models/analyse_ia.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({Key? key}) : super(key: key);

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  bool _loading = true;
  String? _error;
  List<ServiceHospitalier> _services = [];
  Map<int, AnalyseIA> _analyseParService = {};
  Map<int, int> _scoreParService = {};
  Map<int, String> _evolutionParService = {};
  Map<int, String> _simulationResult = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final services = await ApiService.getServices();
      final Map<int, AnalyseIA> analyseServices = {};
      final Map<int, int> scoreServices = {};
      final Map<int, String> evolServices = {};
      for (final s in services) {
        if (s.idService != null) {
          try {
            final analyse = await ApiService.getAnalyseIAService(s.idService!);
            analyseServices[s.idService!] = analyse;
            // Score IA simulé (à remplacer par backend)
            scoreServices[s.idService!] = 60 + (s.idService! * 7) % 40;
            evolServices[s.idService!] = '+2 pts';
          } catch (_) {}
        }
      }
      setState(() {
        _services = services;
        _analyseParService = analyseServices;
        _scoreParService = scoreServices;
        _evolutionParService = evolServices;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _simulerMoisProchain(int idService) async {
    setState(() { _simulationResult[idService] = 'Simulation en cours...'; });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _simulationResult[idService] = 'Résultat IA : Dépassement probable';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des services hospitaliers')),
      drawer: AppDrawer(currentRoute: '/admin/services', isAdmin: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur : $_error'))
              : ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: _services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (ctx, i) {
                    final s = _services[i];
                    final analyse = _analyseParService[s.idService ?? -1];
                    final score = _scoreParService[s.idService ?? -1] ?? 0;
                    final evol = _evolutionParService[s.idService ?? -1] ?? '';
                    final sim = _simulationResult[s.idService ?? -1];
                    return Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.business, color: Colors.indigo.shade400),
                                const SizedBox(width: 10),
                                Text(s.nomService, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('Score IA : ', style: const TextStyle(fontWeight: FontWeight.w500)),
                                Text('$score/100', style: TextStyle(fontWeight: FontWeight.bold, color: score >= 80 ? Colors.green : (score >= 60 ? Colors.orange : Colors.red))),
                                const SizedBox(width: 12),
                                Text('Évolution : $evol', style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
                              ],
                            ),
                            // Tendance IA désactivée (champ non présent dans AnalyseIA)
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.science),
                                  label: const Text('Simuler le mois prochain'),
                                  onPressed: () => _simulerMoisProchain(s.idService!),
                                ),
                                if (sim != null) ...[
                                  const SizedBox(width: 12),
                                  Text(sim, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
