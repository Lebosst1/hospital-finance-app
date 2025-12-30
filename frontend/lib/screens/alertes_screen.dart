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
    final typeCtrl = TextEditingController(text: initial?.type ?? 'Budget');
    final msgCtrl = TextEditingController(text: initial?.message ?? '');
    final niveauCtrl = TextEditingController(text: initial?.niveau ?? 'WARNING');
    final dateCtrl = TextEditingController(text: initial?.dateAlerte != null && initial!.dateAlerte.length >= 19
      ? initial.dateAlerte.substring(0, 19)
      : '');
    final idServiceCtrl = TextEditingController(text: initial?.idService?.toString() ?? '');
    final statutCtrl = TextEditingController(text: initial?.statut ?? 'NOUVELLE');

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
                    controller: typeCtrl,
                    decoration: const InputDecoration(labelText: 'Type d\'alerte (obligatoire)'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: msgCtrl,
                    decoration: const InputDecoration(labelText: 'Message (obligatoire)'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: niveauCtrl,
                    decoration: const InputDecoration(labelText: 'Niveau (INFO / WARNING / CRITIQUE)'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: dateCtrl,
                    decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: idServiceCtrl,
                    decoration: const InputDecoration(labelText: 'ID Service'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: statutCtrl,
                    decoration: const InputDecoration(labelText: 'Statut (NOUVELLE, VALIDEE, EN_COURS, RESOLUE)'),
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

                // Correction : forcer le format yyyy-MM-ddTHH:mm:ss
                String dateAlerteStr;
                if (dateCtrl.text.trim().isEmpty) {
                  final now = DateTime.now();
                  dateAlerteStr = now.toIso8601String().split('.').first;
                } else {
                  final txt = dateCtrl.text.trim();
                  // Si l'utilisateur saisit juste une date, on complète avec T00:00:00
                  if (txt.length == 10 && txt.contains('-') && !txt.contains('T')) {
                    dateAlerteStr = "${txt}T00:00:00";
                  } else if (txt.length >= 19) {
                    dateAlerteStr = txt.substring(0, 19);
                  } else if (txt.length >= 16 && txt.contains('T')) {
                    // Si l'utilisateur tape "2025-12-30T11:00", on complète avec ":00"
                    dateAlerteStr = txt + ":00";
                  } else {
                    dateAlerteStr = txt;
                  }
                }
                final a = Alerte(
                  idAlerte: initial?.idAlerte,
                  type: typeCtrl.text.trim(),
                  message: msgCtrl.text.trim(),
                  niveau: niveauCtrl.text.trim().isEmpty ? 'WARNING' : niveauCtrl.text.trim(),
                  dateAlerte: dateAlerteStr,
                  idService: idServiceCtrl.text.trim().isEmpty ? null : int.tryParse(idServiceCtrl.text.trim()),
                  statut: statutCtrl.text.trim().isEmpty ? 'NOUVELLE' : statutCtrl.text.trim(),
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
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
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
                                        'Type : ${a.type} • Niveau : ${a.niveau} • Statut : ${a.statut} • Date : ${a.dateAlerte}'),
                                    if (a.nomService != null)
                                      Text('Service : ${a.nomService}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (a.statut != 'VALIDEE')
                                      IconButton(
                                        icon: const Icon(Icons.verified_user),
                                        tooltip: 'Valider',
                                        onPressed: () async {
                                          setState(() => _isLoading = true);
                                          try {
                                            await ApiService.validerAlerte(a.idAlerte!);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Alerte validée ✅')),
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
                                        },
                                      ),
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
                    ],
                  ),
      ),
    );
  }
}
