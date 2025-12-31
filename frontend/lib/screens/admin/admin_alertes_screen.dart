import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../services/api_service.dart';
import '../../models/alerte.dart';

class AdminAlertesScreen extends StatefulWidget {
  const AdminAlertesScreen({Key? key}) : super(key: key);

  @override
  State<AdminAlertesScreen> createState() => _AdminAlertesScreenState();
}

class _AdminAlertesScreenState extends State<AdminAlertesScreen> {
  bool _loading = true;
  String? _error;
  List<Alerte> _alertes = [];
  Map<int, Map<String, String>> _iaInfos = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final alertes = await ApiService.getAlertes();
      // Simule un appel IA pour chaque alerte (à remplacer par un vrai endpoint si dispo)
      final Map<int, Map<String, String>> iaInfos = {};
      for (final a in alertes) {
        // Exemples de priorisation et cause probable IA
        String prio = 'ℹ Information';
        String cause = 'Non déterminée';
        if (a.niveau.toUpperCase().contains('CRIT')) {
          prio = '🔥 Critique';
          cause = 'Dépassement budget + admissions élevées';
        } else if (a.niveau.toUpperCase().contains('WARN')) {
          prio = '⚠ Modérée';
          cause = 'Hausse séjours ou consommables';
        }
        iaInfos[a.idAlerte ?? -1] = {'prio': prio, 'cause': cause};
      }
      setState(() {
        _alertes = alertes;
        _iaInfos = iaInfos;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des alertes')),
      drawer: AppDrawer(currentRoute: '/admin/alertes', isAdmin: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur : $_error'))
              : _alertes.isEmpty
                  ? const Center(child: Text('Aucune alerte détectée.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(18),
                      itemCount: _alertes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final a = _alertes[i];
                        final ia = _iaInfos[a.idAlerte ?? -1] ?? {};
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            leading: Text(
                              ia['prio'] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            title: Text(a.message),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (a.nomService != null) Text('Service : ${a.nomService}'),
                                Text('Date : ${a.dateAlerte}'),
                                if (ia['cause'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text('Cause probable (IA) : ${ia['cause']}', style: const TextStyle(fontStyle: FontStyle.italic)),
                                ],
                              ],
                            ),
                            trailing: Text(a.statut, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
    );
  }
}
