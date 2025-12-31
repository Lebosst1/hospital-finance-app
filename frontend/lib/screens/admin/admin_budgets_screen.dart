import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../models/service_hospitalier.dart';
import '../../services/api_service.dart';

class AdminBudgetsScreen extends StatefulWidget {
  const AdminBudgetsScreen({Key? key}) : super(key: key);

  @override
  State<AdminBudgetsScreen> createState() => _AdminBudgetsScreenState();
}

class _AdminBudgetsScreenState extends State<AdminBudgetsScreen> {
    Future<void> _editServiceDialog(ServiceHospitalier service) async {
      final budgetCtrl = TextEditingController(text: service.budgetMensuel?.toStringAsFixed(0) ?? '');
      final seuilCtrl = TextEditingController(text: service.seuilAlerte?.toStringAsFixed(0) ?? '');
      final result = await showDialog<ServiceHospitalier>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Modifier ${service.nomService}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Budget mensuel (DH)'),
              ),
              TextField(
                controller: seuilCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Seuil d’alerte (%)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                final double? budget = double.tryParse(budgetCtrl.text);
                final double? seuil = double.tryParse(seuilCtrl.text);
                if (budget != null && seuil != null) {
                  Navigator.pop(ctx, service.copyWith(budgetMensuel: budget, seuilAlerte: seuil));
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      );
      if (result != null) {
        try {
          await ApiService.updateService(result);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service mis à jour !')));
          _loadData();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
        }
      }
    }
  bool _loading = true;
  String? _error;
  List<ServiceHospitalier> _services = [];
  double _seuilOrange = 80;
  double _seuilRouge = 95;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final services = await ApiService.getServices();
      setState(() {
        _services = services;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Budgets et seuils d'alerte")),
      drawer: AppDrawer(currentRoute: '/admin/budgets', isAdmin: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur : $_error'))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Card(
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.account_balance_wallet),
                        title: const Text('Budget global'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Budget mensuel : ' + _services.fold<double>(0, (sum, s) => sum + (s.budgetMensuel ?? 0)).toStringAsFixed(0) + ' DH'),
                            // TODO: Dépense actuelle réelle
                            Text('Dépense actuelle : ...'),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: LinearProgressIndicator(value: 0.0, minHeight: 8),
                            ),
                            Text('...% consommé'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ListTile(
                            leading: Icon(Icons.business),
                            title: Text('Budgets par service'),
                          ),
                          ..._services.map((s) => ListTile(
                                title: Text(s.nomService),
                                subtitle: Text('Alloué : ${s.budgetMensuel?.toStringAsFixed(0) ?? '-'} DH, Dépensé : ...'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editServiceDialog(s),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ListTile(
                            leading: Icon(Icons.warning_amber),
                            title: Text('Seuils d’alerte'),
                          ),
                          ListTile(
                            title: const Text('Alerte orange'),
                            trailing: SizedBox(
                              width: 120,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value: _seuilOrange,
                                      min: 50,
                                      max: 100,
                                      divisions: 10,
                                      label: '${_seuilOrange.toInt()}%',
                                      onChanged: (v) => setState(() => _seuilOrange = v),
                                    ),
                                  ),
                                  Text('${_seuilOrange.toInt()}%'),
                                ],
                              ),
                            ),
                          ),
                          ListTile(
                            title: const Text('Alerte rouge'),
                            trailing: SizedBox(
                              width: 120,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value: _seuilRouge,
                                      min: 50,
                                      max: 100,
                                      divisions: 10,
                                      label: '${_seuilRouge.toInt()}%',
                                      onChanged: (v) => setState(() => _seuilRouge = v),
                                    ),
                                  ),
                                  Text('${_seuilRouge.toInt()}%'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
