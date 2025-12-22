// lib/screens/previsions_screen.dart
import 'package:flutter/material.dart';
import '../models/prevision.dart';
import '../services/api_service.dart';
import '../main.dart';

class PrevisionsScreen extends StatefulWidget {
  const PrevisionsScreen({super.key});

  @override
  State<PrevisionsScreen> createState() => _PrevisionsScreenState();
}

class _PrevisionsScreenState extends State<PrevisionsScreen> {
  bool _isLoading = false;
  List<Prevision> _previsions = [];

  @override
  void initState() {
    super.initState();
    _loadPrevisions();
  }

  Future<void> _loadPrevisions() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.getPrevisions();
      setState(() {
        _previsions = list;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement prévisions : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showPrevisionDialog({Prevision? initial}) async {
    final coutCtrl = TextEditingController(
        text: initial?.coutPrevu.toStringAsFixed(0) ?? '');
    final dateCtrl =
        TextEditingController(text: initial?.dateCalcul ?? '');
    final idServiceCtrl =
        TextEditingController(text: initial?.idService?.toString() ?? '');

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Prevision>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(initial == null
              ? 'Ajouter une prévision'
              : 'Modifier la prévision'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: coutCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Coût prévu (DH)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: dateCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Date de calcul (YYYY-MM-DD)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: idServiceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ID Service',
                    ),
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

                final prev = Prevision(
                  idPrevision: initial?.idPrevision,
                  coutPrevu:
                      double.tryParse(coutCtrl.text.trim()) ?? 0.0,
                  dateCalcul: dateCtrl.text.trim().isEmpty
                      ? DateTime.now().toIso8601String()
                      : dateCtrl.text.trim(),
                  idService: idServiceCtrl.text.trim().isEmpty
                      ? null
                      : int.tryParse(idServiceCtrl.text.trim()),
                );

                Navigator.pop(ctx, prev);
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
        await ApiService.createPrevision(result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prévision créée ✅')),
        );
      } else {
        await ApiService.updatePrevision(result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prévision mise à jour ✅')),
        );
      }
      await _loadPrevisions();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete(Prevision prev) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Supprimer la prévision'),
          content:
              const Text('Voulez-vous vraiment supprimer cette prévision ?'),
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

    if (ok != true || prev.idPrevision == null) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.deletePrevision(prev.idPrevision!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prévision supprimée ✅')),
      );
      await _loadPrevisions();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _totalPrevu => _previsions
      .map((p) => p.coutPrevu)
      .fold(0.0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/previsions'),
      appBar: AppBar(
        title: const Text('Prévisions financières'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPrevisionDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle prévision'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.summarize),
                      title: const Text('Total prévu'),
                      subtitle: Text('${_totalPrevu.toStringAsFixed(0)} DH'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _previsions.isEmpty
                        ? const Center(
                            child: Text('Aucune prévision trouvée.'),
                          )
                        : ListView.builder(
                            itemCount: _previsions.length,
                            itemBuilder: (context, index) {
                              final p = _previsions[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(
                                      p.nomService ?? 'Service #${p.idService ?? 0}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Coût prévu : ${p.coutPrevu.toStringAsFixed(0)} DH'),
                                      Text('Date : ${p.dateCalcul}'),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () =>
                                            _showPrevisionDialog(initial: p),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _confirmDelete(p),
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
