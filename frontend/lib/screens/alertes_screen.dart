// lib/screens/alertes_screen.dart
import 'package:flutter/material.dart';
import '../models/alerte.dart';
import '../services/api_service.dart';
import '../main.dart';

class AlertesScreen extends StatefulWidget {
  const AlertesScreen({super.key});

  @override
  State<AlertesScreen> createState() => _AlertesScreenState();
}

class _AlertesScreenState extends State<AlertesScreen> {
  bool _isLoading = false;
  List<Alerte> _alertes = [];

  @override
  void initState() {
    super.initState();
    _loadAlertes();
  }

  Future<void> _loadAlertes() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.getAlertes();
      setState(() {
        _alertes = list;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement alertes : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _niveauColor(String niveau) {
    switch (niveau.toUpperCase()) {
      case 'CRITIQUE':
        return Colors.red.shade700;
      case 'WARNING':
      case 'ALERTE':
        return Colors.orange.shade700;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _showAlerteDialog({Alerte? initial}) async {
    final msgCtrl = TextEditingController(text: initial?.message ?? '');
    final niveauCtrl =
        TextEditingController(text: initial?.niveau ?? 'WARNING');
    final dateCtrl =
        TextEditingController(text: initial?.dateAlerte ?? '');
    final idServiceCtrl =
        TextEditingController(text: initial?.idService?.toString() ?? '');

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Alerte>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
              initial == null ? 'Créer une alerte' : 'Modifier l’alerte'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: msgCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Message (obligatoire)'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: niveauCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Niveau (INFO / WARNING / CRITIQUE)'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: dateCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Date (YYYY-MM-DD)'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: idServiceCtrl,
                    decoration:
                        const InputDecoration(labelText: 'ID Service'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final a = Alerte(
                  idAlerte: initial?.idAlerte,
                  message: msgCtrl.text.trim(),
                  niveau: niveauCtrl.text.trim().isEmpty
                      ? 'WARNING'
                      : niveauCtrl.text.trim(),
                  dateAlerte: dateCtrl.text.trim().isEmpty
                      ? DateTime.now().toIso8601String()
                      : dateCtrl.text.trim(),
                  idService: idServiceCtrl.text.trim().isEmpty
                      ? null
                      : int.tryParse(idServiceCtrl.text.trim()),
                );

                Navigator.pop(ctx, a);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    setState(() => _isLoading = true);
    try {
      if (initial == null) {
        await ApiService.createAlerte(result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerte créée ✅')),
        );
      } else {
        // pour simplifier : on supprime puis recrée (sinon faire update côté backend)
        if (initial.idAlerte != null) {
          await ApiService.deleteAlerte(initial.idAlerte!);
        }
        await ApiService.createAlerte(result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerte mise à jour ✅')),
        );
      }
      await _loadAlertes();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete(Alerte alerte) async {
    if (alerte.idAlerte == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Supprimer l’alerte'),
          content:
              const Text('Voulez-vous vraiment supprimer cette alerte ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.deleteAlerte(alerte.idAlerte!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alerte supprimée ✅')),
      );
      await _loadAlertes();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/alertes'),
      appBar: AppBar(
        title: const Text('Alertes budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlertes,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAlerteDialog(),
        icon: const Icon(Icons.add_alert),
        label: const Text('Nouvelle alerte'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _alertes.isEmpty
                ? const Center(child: Text('Aucune alerte.'))
                : ListView.builder(
                    itemCount: _alertes.length,
                    itemBuilder: (context, index) {
                      final a = _alertes[index];
                      final color = _niveauColor(a.niveau);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(Icons.warning_amber, color: color),
                          title: Text(
                            a.message,
                            style: TextStyle(color: color),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Niveau : ${a.niveau} • Date : ${a.dateAlerte}'),
                              if (a.nomService != null)
                                Text('Service : ${a.nomService}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _showAlerteDialog(initial: a),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _confirmDelete(a),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
