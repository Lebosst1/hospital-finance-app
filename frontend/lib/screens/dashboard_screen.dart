
import 'package:flutter/material.dart';
import '../models/service_hospitalier.dart';
import '../services/api_service.dart';
import '../widgets/bar_chart_widget.dart';
import 'quick_access_pager.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {

    // Pour stocker les données graphiques IA
    Map<String, double>? _globalMoisData;
    Map<String, double>? _globalAnneeData;
    Map<String, Map<String, double>>? _parServiceAnneeData;
  bool _isLoading = false;
  bool _isAdmin = false;
  String _userName = '';

  List<ServiceHospitalier> _services = [];
  List<ServiceHospitalier> _filteredServices = [];
  String _searchQuery = '';

  String _sortMode = 'nom'; // nom | mensuel_desc | annuel_desc

  // Pour stocker l'analyse IA globale (annuelle)
  double? _iaAnnuelTotal;
  Map<String, dynamic>? _iaGlobaleData;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadServices();
  }

  Future<void> _loadUserInfo() async {
    final role = await ApiService.getUserRole();
    final name = await ApiService.getUserName();

    print('DEBUG ROLE: ' + (role ?? 'null') + ', USERNAME: ' + (name ?? 'null'));
    setState(() {
      _isAdmin = (role?.toUpperCase() == 'ADMIN');
      _userName = name ?? '';
    });
  }

  // ==========================
  //   CHARGER DONNÉES
  // ==========================
  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.getServices();
      setState(() {
        _services = list;
        _applyFilter();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement services : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================
  //   RECHERCHE / TRI
  // ==========================
  void _applyFilter() {
    if (_searchQuery.trim().isEmpty) {
      _filteredServices = List.from(_services);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredServices = _services
          .where((s) => s.nomService.toLowerCase().contains(q))
          .toList();
    }
    _applySort();
  }

  void _applySort() {
    _filteredServices.sort((a, b) {
      switch (_sortMode) {
        case 'mensuel_desc':
          final am = a.budgetMensuel ?? 0;
          final bm = b.budgetMensuel ?? 0;
          return bm.compareTo(am); // décroissant
        case 'annuel_desc':
          final aa = a.budgetAnnuel ?? 0;
          final ba = b.budgetAnnuel ?? 0;
          return ba.compareTo(aa); // décroissant
        case 'nom':
        default:
          return a.nomService.toLowerCase().compareTo(
                b.nomService.toLowerCase(),
              );
      }
    });
  }

  // ==========================
  //   AJOUT / MODIF SERVICE
  // ==========================
  Future<void> _showServiceDialog({ServiceHospitalier? initial}) async {
    final nameCtrl =
        TextEditingController(text: initial != null ? initial.nomService : '');
    final mensuelCtrl = TextEditingController(
        text: initial?.budgetMensuel?.toStringAsFixed(0) ?? '');
    final annuelCtrl = TextEditingController(
        text: initial?.budgetAnnuel?.toStringAsFixed(0) ?? '');
    final seuilCtrl = TextEditingController(
        text: initial?.seuilAlerte?.toStringAsFixed(0) ?? '');

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<ServiceHospitalier>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title:
              Text(initial == null ? 'Ajouter un service' : 'Modifier le service'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Nom du service'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Nom obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: mensuelCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Budget mensuel (DH)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: annuelCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Budget annuel (DH)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: seuilCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Seuil alerte (DH)'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
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

                double? parseOrNull(String s) =>
                    s.trim().isEmpty ? null : double.tryParse(s.trim());

                final service = ServiceHospitalier(
                  idService: initial?.idService,
                  nomService: nameCtrl.text.trim(),
                  budgetMensuel: parseOrNull(mensuelCtrl.text),
                  budgetAnnuel: parseOrNull(annuelCtrl.text),
                  seuilAlerte: parseOrNull(seuilCtrl.text),
                );

                Navigator.pop(ctx, service);
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
        await ApiService.createService(result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service créé ✅')),
        );
      } else {
        await ApiService.updateService(result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service mis à jour ✅')),
        );
      }
      await _loadServices();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================
  //   SUPPRESSION
  // ==========================
  Future<void> _confirmDelete(ServiceHospitalier service) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Supprimer le service'),
          content: Text(
              'Voulez-vous vraiment supprimer le service "${service.nomService}" ?'),
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
      await ApiService.deleteService(service.idService!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service supprimé ✅')),
      );
      await _loadServices();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================
  //   LOGOUT
  // ==========================
  Future<void> _handleLogout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ==========================
  //   CALCUL KPIs
  // ==========================
  int get _nbServices => _services.length;

  double get _totalMensuel =>
      _services.map((s) => s.budgetMensuel ?? 0).fold(0.0, (a, b) => a + b);

  double get _totalAnnuel =>
      _services.map((s) => s.budgetAnnuel ?? 0).fold(0.0, (a, b) => a + b);

  // ==========================
  //   BUILD
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Text('Hospital Finance Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            if (_isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          if (_userName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Bienvenue, $_userName'),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFe0e7ff), Color(0xFFfdf6ff)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 80.0, left: 16, right: 16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Accès rapide sous forme de PageView avec flèches
                    SizedBox(
                      height: 160,
                      child: QuickAccessPager(),
                    ),

                    const SizedBox(height: 40),
                    // Un petit résumé KPIs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildKpiCard(
                            title: 'Nombre de services',
                            value: _nbServices.toString(),
                            icon: Icons.local_hospital,
                          ),
                          const SizedBox(width: 24),
                          _buildKpiCard(
                            title: 'Budget mensuel total',
                            value: '${_totalMensuel.toStringAsFixed(0)} DH',
                            icon: Icons.calendar_view_month,
                          ),
                          const SizedBox(width: 24),
                          _buildKpiCard(
                            title: 'Budget annuel total',
                            value: '${_totalAnnuel.toStringAsFixed(0)} DH',
                            icon: Icons.calendar_today,
                          ),
                        ],
                      ),
                    ),
                    // On peut ajouter d'autres widgets ici si besoin
                  ],
                ),
        ),
      ),
    );
  }

  // Widget accès rapide
  Widget _quickAccessCard({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: color.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: SizedBox(
          width: 140,
          height: 120,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: color),
                const SizedBox(height: 12),
                Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget KPI
  Widget _buildKpiCard({required String title, required String value, required IconData icon}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blueGrey, size: 32),
            const SizedBox(width: 12),
            Column(
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
          ],
        ),
      ),
    );
  }
}
 