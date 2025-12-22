import 'package:flutter/material.dart';
import '../models/sejour.dart';
import '../models/service_hospitalier.dart';
import '../models/patient.dart';
import '../services/api_service.dart';

class SejoursScreen extends StatefulWidget {
  const SejoursScreen({super.key});

  @override
  State<SejoursScreen> createState() => _SejoursScreenState();
}

class _SejoursScreenState extends State<SejoursScreen> {
  bool _isLoading = false;

  List<Sejour> _sejours = [];
  List<Sejour> _filteredSejours = [];

  List<ServiceHospitalier> _services = [];
  List<Patient> _patients = [];

  String _searchQuery = '';
  String _sortMode = 'date_desc'; // date_desc | cout_desc | jours_desc

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // ==========================
  //   CHARGEMENT DONNÉES
  // ==========================

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getSejours(),
        ApiService.getServices(),
        ApiService.getPatients(),
      ]);

      setState(() {
        _sejours = results[0] as List<Sejour>;
        _services = results[1] as List<ServiceHospitalier>;
        _patients = results[2] as List<Patient>;
        _applyFilter();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement séjours : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================
  //   HELPERS NOM SERVICE / PATIENT
  // ==========================

  String _serviceName(int? idService) {
    if (idService == null) return 'Service ?';
    final s = _services.firstWhere(
      (srv) => srv.idService == idService,
      orElse: () => ServiceHospitalier(
        idService: null,
        nomService: 'Service ?',
      ),
    );
    return s.nomService;
  }

  String _patientName(int? idPatient) {
    if (idPatient == null) return 'Patient ?';
    final p = _patients.firstWhere(
      (pat) => pat.idPatient == idPatient,
      orElse: () => Patient(
        idPatient: null,
        nom: 'Inconnu',
        prenom: 'Patient',
      ),
    );
    return p.fullName;
  }

  DateTime _parseDate(String? s) {
    if (s == null || s.isEmpty) return DateTime(1970, 1, 1);
    return DateTime.tryParse(s) ?? DateTime(1970, 1, 1);
  }

  // ==========================
  //   RECHERCHE + TRI
  // ==========================

  void _applyFilter() {
    if (_searchQuery.trim().isEmpty) {
      _filteredSejours = List.from(_sejours);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredSejours = _sejours.where((s) {
        final serviceName = _serviceName(s.idService).toLowerCase();
        final patientName = _patientName(s.idPatient).toLowerCase();
        final coutStr = (s.cout ?? 0).toString().toLowerCase();
        return serviceName.contains(q) ||
            patientName.contains(q) ||
            coutStr.contains(q);
      }).toList();
    }
    _applySort();
  }

  void _applySort() {
    _filteredSejours.sort((a, b) {
      switch (_sortMode) {
        case 'cout_desc':
          final ac = a.cout ?? 0;
          final bc = b.cout ?? 0;
          return bc.compareTo(ac); // décroissant
        case 'jours_desc':
          return b.nbJours.compareTo(a.nbJours);
        case 'date_desc':
        default:
          final da = _parseDate(a.dateEntree);
          final db = _parseDate(b.dateEntree);
          return db.compareTo(da); // plus récents en haut
      }
    });
  }

  // ==========================
  //   DIALOGUE AJOUT / EDIT
  // ==========================

  Future<void> _showSejourDialog({Sejour? initial}) async {
    final nbJoursCtrl = TextEditingController(
      text: initial?.nbJours.toString() ?? '',
    );
    final coutCtrl = TextEditingController(
      text: initial?.cout?.toStringAsFixed(0) ?? '',
    );
    final dateEntreeCtrl = TextEditingController(
      text: initial?.dateEntree ?? '',
    );
    final dateSortieCtrl = TextEditingController(
      text: initial?.dateSortie ?? '',
    );

    int? selectedServiceId = initial?.idService;
    int? selectedPatientId = initial?.idPatient;

    final formKey = GlobalKey<FormState>();

    Future<void> pickDate(
      TextEditingController controller,
    ) async {
      final now = DateTime.now();
      final initialDate = _parseDate(controller.text.isEmpty
          ? null
          : controller.text);

      final picked = await showDatePicker(
        context: context,
        initialDate: initialDate.year == 1970 ? now : initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(now.year + 1),
      );

      if (picked != null) {
        final s =
            '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        controller.text = s;
      }
    }

    final result = await showDialog<Sejour>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            initial == null ? 'Ajouter un séjour' : 'Modifier le séjour',
          ),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Patient
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Patient',
                      ),
                      value: selectedPatientId,
                      items: _patients
                          .map(
                            (p) => DropdownMenuItem<int>(
                              value: p.idPatient,
                              child: Text(p.fullName),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        selectedPatientId = v;
                      },
                      validator: (v) =>
                          v == null ? 'Sélectionnez un patient' : null,
                    ),
                    const SizedBox(height: 12),
                    // Service
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Service hospitalier',
                      ),
                      value: selectedServiceId,
                      items: _services
                          .map(
                            (s) => DropdownMenuItem<int>(
                              value: s.idService,
                              child: Text(s.nomService),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        selectedServiceId = v;
                      },
                      validator: (v) =>
                          v == null ? 'Sélectionnez un service' : null,
                    ),
                    const SizedBox(height: 12),
                    // nbJours
                    TextFormField(
                      controller: nbJoursCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Nombre de jours'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Nombre de jours obligatoire';
                        }
                        if (int.tryParse(v.trim()) == null) {
                          return 'Valeur invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    // cout
                    TextFormField(
                      controller: coutCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Coût (DH)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    // dates
                    TextFormField(
                      controller: dateEntreeCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date d’entrée',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => pickDate(dateEntreeCtrl),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: dateSortieCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date de sortie',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => pickDate(dateSortieCtrl),
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

                final nb = int.tryParse(nbJoursCtrl.text.trim()) ?? 0;
                final cout =
                    coutCtrl.text.trim().isEmpty ? null : double.tryParse(coutCtrl.text.trim());

                final sejour = Sejour(
                  idSejour: initial?.idSejour,
                  nbJours: nb,
                  cout: cout,
                  dateEntree: dateEntreeCtrl.text.trim().isEmpty
                      ? null
                      : dateEntreeCtrl.text.trim(),
                  dateSortie: dateSortieCtrl.text.trim().isEmpty
                      ? null
                      : dateSortieCtrl.text.trim(),
                  idService: selectedServiceId,
                  idPatient: selectedPatientId,
                );

                Navigator.pop(ctx, sejour);
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
        await ApiService.createSejour(result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Séjour créé ✅')),
        );
      } else {
        await ApiService.updateSejour(result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Séjour mis à jour ✅')),
        );
      }
      await _loadAllData();
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

  Future<void> _confirmDelete(Sejour sejour) async {
    final patientName = _patientName(sejour.idPatient);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le séjour'),
        content: Text(
            'Voulez-vous vraiment supprimer le séjour de "$patientName" ?'),
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
      ),
    );

    if (ok != true || sejour.idSejour == null) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.deleteSejour(sejour.idSejour!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Séjour supprimé ✅')),
      );
      await _loadAllData();
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
  //   KPIs
  // ==========================

  int get _nbSejours => _sejours.length;

  double get _totalCout => _sejours
      .map((s) => s.cout ?? 0)
      .fold(0.0, (a, b) => a + b);

  double get _moyenneCout =>
      _nbSejours == 0 ? 0 : _totalCout / _nbSejours;

  double get _moyenneJours {
    if (_nbSejours == 0) return 0;
    final total = _sejours
        .map((s) => s.nbJours)
        .fold<int>(0, (a, b) => a + b);
    return total / _nbSejours;
  }

  // ==========================
  //   BUILD
  // ==========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Séjours – Hospital Finance'),
        actions: [
          IconButton(
            tooltip: 'Dashboard',
            icon: const Icon(Icons.dashboard),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/dashboard'),
          ),
          IconButton(
            tooltip: 'Patients',
            icon: const Icon(Icons.people_alt_outlined),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/patients'),
          ),
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSejourDialog(),
        label: const Text('Ajouter un séjour'),
        icon: const Icon(Icons.add),
      ),
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
                        title: 'Nombre de séjours',
                        value: _nbSejours.toString(),
                        icon: Icons.hotel,
                      ),
                      _buildKpiCard(
                        title: 'Coût total',
                        value: '${_totalCout.toStringAsFixed(0)} DH',
                        icon: Icons.attach_money,
                      ),
                      _buildKpiCard(
                        title: 'Coût moyen / séjour',
                        value: '${_moyenneCout.toStringAsFixed(0)} DH',
                        icon: Icons.balance,
                      ),
                      _buildKpiCard(
                        title: 'Durée moyenne',
                        value: '${_moyenneJours.toStringAsFixed(1)} jours',
                        icon: Icons.av_timer,
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
                            labelText: 'Rechercher (service, patient, coût...)',
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
                                  value: 'date_desc',
                                  child: Text('Date (récent → ancien)'),
                                ),
                                DropdownMenuItem(
                                  value: 'cout_desc',
                                  child: Text('Coût (↘)'),
                                ),
                                DropdownMenuItem(
                                  value: 'jours_desc',
                                  child: Text('Nb jours (↘)'),
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
                    child: _filteredSejours.isEmpty
                        ? const Center(
                            child: Text('Aucun séjour.'),
                          )
                        : ListView.builder(
                            itemCount: _filteredSejours.length,
                            itemBuilder: (context, index) {
                              final s = _filteredSejours[index];
                              final serviceName = _serviceName(s.idService);
                              final patientName = _patientName(s.idPatient);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: const Icon(Icons.bed),
                                  title: Text(
                                    '$patientName – $serviceName',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Nb jours : ${s.nbJours} • Coût : ${(s.cout ?? 0).toStringAsFixed(0)} DH'),
                                      if (s.dateEntree != null ||
                                          s.dateSortie != null)
                                        Text(
                                          'Du ${s.dateEntree ?? '?'} au ${s.dateSortie ?? '?'}',
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () =>
                                            _showSejourDialog(initial: s),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _confirmDelete(s),
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

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return SizedBox(
      width: 240,
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
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 17,
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
