import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart' show MyLocaleChanger;

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _iaActive = true;
  double _sensibilite = 0.5;
  String _horizon = '30j';
  String _lang = 'fr';

  @override
  void initState() {
    super.initState();
    _loadLang();
  }

  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lang = prefs.getString('lang') ?? 'fr';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres système')),
      drawer: AppDrawer(currentRoute: '/admin/settings', isAdmin: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            elevation: 2,
            child: SwitchListTile(
              title: const Text('Activer l’IA décisionnelle'),
              value: _iaActive,
              onChanged: (v) => setState(() => _iaActive = v),
              secondary: const Icon(Icons.smart_toy),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.warning_amber),
              title: const Text('Sensibilité des alertes IA'),
              subtitle: Slider(
                value: _sensibilite,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: (_sensibilite * 100).toStringAsFixed(0) + '%',
                onChanged: (v) => setState(() => _sensibilite = v),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.timeline),
              title: const Text('Horizon de prédiction IA'),
              trailing: DropdownButton<String>(
                value: _horizon,
                items: const [
                  DropdownMenuItem(value: '7j', child: Text('7 jours')),
                  DropdownMenuItem(value: '30j', child: Text('30 jours')),
                ],
                onChanged: (v) => setState(() { if (v != null) _horizon = v; }),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Langue de l’application'),
              trailing: DropdownButton<String>(
                value: _lang,
                items: const [
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (v) async {
                  if (v != null) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('lang', v);
                    setState(() { _lang = v; });
                    // Propagation globale
                    final changer = MyLocaleChanger.of(context);
                    if (changer != null) {
                      changer.changeLocale(Locale(v));
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
