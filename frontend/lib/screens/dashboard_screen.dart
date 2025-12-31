
import 'package:flutter/material.dart';
import '../models/service_hospitalier.dart';
import '../services/api_service.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/ai_insights_card.dart';
import '../widgets/service_budget_tile.dart';
import '../widgets/app_drawer.dart';
import 'quick_access_pager.dart';
import 'dashboard_design_screen.dart';

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
  String _filter = 'Tous'; // Tous | À risque | Anomalies | Dépassés

  String _sortMode = 'nom'; // nom | mensuel_desc | annuel_desc

  // Pour stocker l'analyse IA globale (annuelle)
  double? _iaAnnuelTotal;
  Map<String, dynamic>? _iaGlobaleData;

  // Ajout pour IA et vue/tab
  List<String> _aiInsights = [
    "⚠️ Dépenses anormales détectées en Chirurgie (+18% vs moyenne).",
    "📈 Prévision : dépassement du budget Cardiologie dans 12 jours.",
    "✅ Recommandation : augmenter le seuil d’alerte de Service1 à 80%."
  ];
  int _selectedTab = 0; // 0: IA, 1: Budgets

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
    List<ServiceHospitalier> base = List.from(_services);
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      base = base.where((s) => s.nomService.toLowerCase().contains(q)).toList();
    }
    // Filtre IA
    if (_filter == 'À risque') {
      base = base.where((s) => s.nomService.toLowerCase().contains('cardio')).toList(); // exemple
    } else if (_filter == 'Anomalies') {
      base = base.where((s) => s.nomService.toLowerCase().contains('chir')).toList(); // exemple
    } else if (_filter == 'Dépassés') {
      base = base.where((s) => (s.budgetAnnuel ?? 0) < 10000).toList(); // exemple
    }
    _filteredServices = base;
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
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        title: const Text('Budgets et seuils d\'alerte'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      drawer: AppDrawer(isAdmin: _isAdmin, currentRoute: '/dashboard'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Action IA (ouvrir bottom sheet ou page)
          showModalBottomSheet(
            context: context,
            builder: (ctx) => Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("✨ Demander à l’IA", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ..._aiInsights.map((i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(i, style: const TextStyle(fontSize: 16)),
                  )),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.analytics),
                    label: const Text("Fermer"),
                  )
                ],
              ),
            ),
          );
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text("Demander à l’IA"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tabs IA/Budget
              Row(
                children: [
                  ChoiceChip(
                    label: const Text("Vue IA"),
                    selected: _selectedTab == 0,
                    onSelected: (v) => setState(() => _selectedTab = 0),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text("Vue Budgets"),
                    selected: _selectedTab == 1,
                    onSelected: (v) => setState(() => _selectedTab = 1),
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _filter,
                    items: ["Tous", "À risque", "Anomalies", "Dépassés"]
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() {
                        _filter = v;
                        _applyFilter();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedTab == 0) ...[
                // Bloc IA très visible
                AiInsightsCard(
                  insights: _aiInsights,
                  onOpen: () {
                    // Action voir analyse IA
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Analyse IA complète"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _aiInsights.map((i) => Text(i)).toList(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Fermer"),
                          )
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Résumé global
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(child: Text("Budget annuel : ${_totalAnnuel.toStringAsFixed(0)} DH")),
                        Expanded(child: Text("Dépensé : ...")),
                        Expanded(child: Text("Reste : ...")),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Liste services IA
                Expanded(
                  child: ListView.separated(
                    itemCount: _filteredServices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final s = _filteredServices[i];
                      final aiFlag = i == 0 || i == 1; // exemple IA
                      return ServiceBudgetTile(
                        name: s.nomService,
                        allocated: s.budgetAnnuel ?? 0,
                        spent: (s.budgetAnnuel ?? 0) * (0.62 + i * 0.05), // fake
                        aiFlag: aiFlag,
                        onMenu: () {},
                      );
                    },
                  ),
                ),
              ] else ...[
                // Vue budgets classique
                Expanded(
                  child: ListView.separated(
                    itemCount: _filteredServices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final s = _filteredServices[i];
                      return ServiceBudgetTile(
                        name: s.nomService,
                        allocated: s.budgetAnnuel ?? 0,
                        spent: (s.budgetAnnuel ?? 0) * (0.62 + i * 0.05), // fake
                        aiFlag: false,
                        onMenu: () {},
                      );
                    },
                  ),
                ),
              ],
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
  Widget _buildKpiCard({required String title, required String value, required IconData icon, Color color = const Color(0xFF6366f1)}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.18), width: 1.2),
        // Glassmorphism effect
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: color.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 