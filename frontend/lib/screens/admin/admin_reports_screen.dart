import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../widgets/app_drawer.dart';
import '../../services/api_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
    Future<void> _exportPDF() async {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Text(_syntheseIA ?? 'Aucune synthèse IA disponible.'),
          ),
        ),
      );
      final bytes = await pdf.save();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/rapport_ia.pdf');
      await file.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF généré : ${file.path}')),
      );
      // TODO: Ouvrir ou partager le PDF (selon plateforme)
    }

    Future<void> _exportCSV() async {
      final List<List<dynamic>> rows = [
        ['Synthèse IA'],
        [_syntheseIA ?? 'Aucune synthèse IA disponible.'],
      ];
      final csvData = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/rapport_ia.csv');
      await file.writeAsString(csvData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV généré : ${file.path}')),
      );
      // TODO: Ouvrir ou partager le CSV (selon plateforme)
    }
  bool _loading = true;
  String? _error;
  String? _syntheseIA;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Simule un appel backend IA pour synthèse automatique
      await Future.delayed(const Duration(milliseconds: 900));
      _syntheseIA = "Ce mois, les dépenses ont augmenté de 6%, principalement dues à l'achat de consommables médicaux et à une hausse des admissions en cardiologie. Les prévisions IA restent fiables à 92%.";
      setState(() { _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports et exports'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'PDF') {
                await _exportPDF();
              } else if (v == 'CSV') {
                await _exportCSV();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'PDF', child: Text('Exporter en PDF')),
              const PopupMenuItem(value: 'CSV', child: Text('Exporter en CSV')),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(currentRoute: '/admin/reports', isAdmin: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur : $_error'))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (_syntheseIA != null) ...[
                      Card(
                        color: Colors.indigo.shade50,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_stories, color: Colors.deepPurple, size: 28),
                                  const SizedBox(width: 10),
                                  Text('Synthèse automatique IA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo.shade700)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(_syntheseIA!, style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text('Export PDF/CSV, rapports mensuels/annuels...', style: TextStyle(fontSize: 16)),
                  ],
                ),
    );
  }
}
