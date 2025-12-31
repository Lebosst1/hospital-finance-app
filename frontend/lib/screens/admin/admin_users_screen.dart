import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, String>> _anomalies = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Simule un appel backend IA pour détection comportements inhabituels
      await Future.delayed(const Duration(milliseconds: 800));
      _anomalies = [
        {'user': 'alice', 'anomalie': 'Connexion à 3h du matin (inhabituel)'},
        {'user': 'bob', 'anomalie': 'Accès répétés à la page finances'},
        {'user': 'carol', 'anomalie': 'Tentative d’accès non autorisé'},
      ];
      setState(() { _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      drawer: AppDrawer(currentRoute: '/admin/users', isAdmin: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur : $_error'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text('Détection IA de comportements inhabituels', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo.shade700)),
                    ),
                    if (_anomalies.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(18.0),
                        child: Text('Aucune anomalie détectée.'),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          itemCount: _anomalies.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (ctx, i) {
                            final a = _anomalies[i];
                            return ListTile(
                              leading: const Icon(Icons.warning_amber, color: Colors.orange),
                              title: Text(a['user'] ?? ''),
                              subtitle: Text(a['anomalie'] ?? ''),
                            );
                          },
                        ),
                      ),
                  ],
                ),
    );
  }
}
