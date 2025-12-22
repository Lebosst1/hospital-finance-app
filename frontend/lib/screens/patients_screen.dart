import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/api_service.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  bool _isLoading = false;
  List<Patient> _patients = [];
  List<Patient> _filtered = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.getPatients();
      setState(() {
        _patients = list;
        _applyFilter();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement patients : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    if (_search.trim().isEmpty) {
      _filtered = List.from(_patients);
    } else {
      final q = _search.toLowerCase();
      _filtered = _patients.where((p) {
        return p.fullName.toLowerCase().contains(q) ||
            (p.adresse ?? '').toLowerCase().contains(q) ||
            (p.telephone ?? '').toLowerCase().contains(q);
      }).toList();
    }
  }

  Future<void> _showPatientDialog({Patient? initial}) async {
    final nomCtrl = TextEditingController(text: initial?.nom ?? '');
    final prenomCtrl = TextEditingController(text: initial?.prenom ?? '');
    final telCtrl = TextEditingController(text: initial?.telephone ?? '');
    final adresseCtrl = TextEditingController(text: initial?.adresse ?? '');
    final dateCtrl = TextEditingController(text: initial?.dateNaissance ?? '');
    String sexe = initial?.sexe ?? 'H';

    final formKey = GlobalKey<FormState>();

    Future<void> pickDate() async {
      final now = DateTime.now();
      final initialDate = initial?.dateNaissance != null
          ? DateTime.tryParse(initial!.dateNaissance!)
          : DateTime(now.year - 30);

      final picked = await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime(now.year - 30),
        firstDate: DateTime(1900),
        lastDate: now,
      );

      if (picked != null) {
        // format simple yyyy-MM-dd
        final s =
            '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        dateCtrl.text = s;
      }
    }

    final result = await showDialog<Patient>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(initial == null
              ? 'Ajouter un patient'
              : 'Modifier le patient'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nomCtrl,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Nom obligatoire' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: prenomCtrl,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Prénom obligatoire'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Sexe :'),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          value: sexe,
                          items: const [
                            DropdownMenuItem(
                              value: 'H',
                              child: Text('Homme'),
                            ),
                            DropdownMenuItem(
                              value: 'F',
                              child: Text('Femme'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            sexe = v;
                            // pas besoin de setState ici, c'est juste pour la valeur
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: telCtrl,
                      decoration: const InputDecoration(labelText: 'Téléphone'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: adresseCtrl,
                      decoration: const InputDecoration(labelText: 'Adresse'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: dateCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date de naissance',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: pickDate,
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

                final p = Patient(
                  idPatient: initial?.idPatient,
                  nom: nomCtrl.text.trim(),
                  prenom: prenomCtrl.text.trim(),
                  sexe: sexe,
                  telephone:
                      telCtrl.text.trim().isEmpty ? null : telCtrl.text.trim(),
                  adresse: adresseCtrl.text.trim().isEmpty
                      ? null
                      : adresseCtrl.text.trim(),
                  dateNaissance:
                      dateCtrl.text.trim().isEmpty ? null : dateCtrl.text.trim(),
                );

                Navigator.pop(ctx, p);
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
        await ApiService.createPatient(result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient créé ✅')),
        );
      } else {
        await ApiService.updatePatient(result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient mis à jour ✅')),
        );
      }
      await _loadPatients();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete(Patient p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le patient'),
        content:
            Text('Voulez-vous vraiment supprimer "${p.fullName}" ?'),
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

    if (ok != true || p.idPatient == null) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.deletePatient(p.idPatient!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient supprimé ✅')),
      );
      await _loadPatients();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients – Hospital Finance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Dashboard',
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/dashboard'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: _handleLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPatientDialog(),
        label: const Text('Ajouter un patient'),
        icon: const Icon(Icons.person_add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Rechercher (nom, téléphone, adresse...)',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      setState(() {
                        _search = v;
                        _applyFilter();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filtered.isEmpty
                        ? const Center(child: Text('Aucun patient.'))
                        : ListView.builder(
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final p = _filtered[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(p.fullName),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (p.sexe != null)
                                        Text('Sexe : ${p.sexe == 'H' ? 'Homme' : 'Femme'}'),
                                      if (p.telephone != null &&
                                          p.telephone!.isNotEmpty)
                                        Text('Tel : ${p.telephone}'),
                                      if (p.adresse != null &&
                                          p.adresse!.isNotEmpty)
                                        Text('Adresse : ${p.adresse}'),
                                      if (p.dateNaissance != null &&
                                          p.dateNaissance!.isNotEmpty)
                                        Text('Né(e) le : ${p.dateNaissance}'),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () =>
                                            _showPatientDialog(initial: p),
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
