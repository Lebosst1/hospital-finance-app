import 'package:flutter/material.dart';
import '../models/service_hospitalier.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;
  bool _isAdmin = false;
  String _userName = '';

  List<ServiceHospitalier> _services = [];
  List<ServiceHospitalier> _filteredServices = [];
  String _searchQuery = '';

  String _sortMode = 'nom'; // nom | mensuel_desc | annuel_desc

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadServices();
  }

  Future<void> _loadUserInfo() async {
    final role = await ApiService.getUserRole();
    final name = await ApiService.getUserName();

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
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Hospital Finance Dashboard'),
            const SizedBox(width: 16),
            if (_isAdmin)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              child: Center(
                child: Text(
                  _userName,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/sejours'),
            icon: const Icon(Icons.bed, color: Colors.white),
            label: const Text(
              'Séjours',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/patients'),
            icon: const Icon(Icons.people, color: Colors.white),
            label: const Text(
              'Patients',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/finance'),
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            label: const Text(
              'Finance',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showServiceDialog(),
              label: const Text('Ajouter un service'),
              icon: const Icon(Icons.add),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- KPIs ----------
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildKpiCard(
                        title: 'Nombre de services',
                        value: _nbServices.toString(),
                        icon: Icons.local_hospital,
                      ),
                      _buildKpiCard(
                        title: 'Budget mensuel total',
                        value: '${_totalMensuel.toStringAsFixed(0)} DH',
                        icon: Icons.calendar_view_month,
                      ),
                      _buildKpiCard(
                        title: 'Budget annuel total',
                        value: '${_totalAnnuel.toStringAsFixed(0)} DH',
                        icon: Icons.calendar_today,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ---------- RECHERCHE + TRI ----------
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Rechercher un service',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                              _applyFilter();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 220,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Trier par',
                            border: OutlineInputBorder(),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortMode,
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() {
                                  _sortMode = v;
                                  _applySort();
                                });
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: 'nom',
                                  child: Text('Nom (A → Z)'),
                                ),
                                DropdownMenuItem(
                                  value: 'mensuel_desc',
                                  child: Text('Budget mensuel (↘)'),
                                ),
                                DropdownMenuItem(
                                  value: 'annuel_desc',
                                  child: Text('Budget annuel (↘)'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ---------- LISTE ----------
                  Expanded(
                    child: _filteredServices.isEmpty
                        ? const Center(
                            child: Text('Aucun service trouvé.'),
                          )
                        : ListView.builder(
                            itemCount: _filteredServices.length,
                            itemBuilder: (context, index) {
                              final s = _filteredServices[index];

                              final bool isAlerte = s.budgetMensuel != null &&
                                  s.seuilAlerte != null &&
                                  s.budgetMensuel! < s.seuilAlerte!;

                              return Card(
                                color: isAlerte
                                    ? Colors.red.shade50
                                    : const Color(0xFFF7F2FF),
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(
                                    s.nomService,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (s.budgetMensuel != null)
                                        Text(
                                            'Budget mensuel : ${s.budgetMensuel} DH'),
                                      if (s.budgetAnnuel != null)
                                        Text(
                                            'Budget annuel : ${s.budgetAnnuel} DH'),
                                      if (s.seuilAlerte != null)
                                        Text(
                                          'Seuil alerte : ${s.seuilAlerte} DH',
                                          style: TextStyle(
                                            color: isAlerte
                                                ? Colors.red.shade700
                                                : Colors.black87,
                                          ),
                                        ),
                                      if (isAlerte)
                                        const Text(
                                          '⚠️ Budget sous le seuil !',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: _isAdmin
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              tooltip: 'Modifier',
                                              onPressed: () =>
                                                  _showServiceDialog(
                                                      initial: s),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              tooltip: 'Supprimer',
                                              onPressed: s.idService == null
                                                  ? null
                                                  : () => _confirmDelete(s),
                                            ),
                                          ],
                                        )
                                      : const Icon(Icons.chevron_right),
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

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.indigo),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
