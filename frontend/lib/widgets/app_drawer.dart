
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final bool isAdmin;
  final String currentRoute;

  const AppDrawer({
    Key? key,
    required this.isAdmin,
    required this.currentRoute,
  }) : super(key: key);

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    String route, {
    int? badge,
    bool selectedOverride = false,
  }) {
    final selected = selectedOverride || currentRoute == route;
    return Material(
      color: selected ? Colors.blue.shade50 : Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!selected) {
            Navigator.pushReplacementNamed(context, route);
          } else {
            Navigator.pop(context);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: selected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: selected ? Colors.blue : Colors.grey.shade700),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.blue.shade900 : Colors.grey.shade900,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ),
              if (badge != null && badge > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$badge', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.only(top: 36, left: 16, right: 16, bottom: 16),
            width: double.infinity,
            child: Row(
              children: [
                const Icon(Icons.local_hospital, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hospital Finance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(isAdmin ? 'Administrateur' : 'Utilisateur', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      Text('admin@test.com', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Dernière synchro : 09:45', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text('Pilotage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                ),
                _item(context, Icons.dashboard, 'Tableau de bord', '/dashboard'),
                _item(context, Icons.analytics, 'Finances', '/finance'),
                _item(context, Icons.warning, 'Alertes', '/alertes', badge: 4),
                if (isAdmin) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text('Administration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                  ),
                  _item(context, Icons.admin_panel_settings, 'Dashboard admin', '/admin'),
                  _item(context, Icons.people, 'Gestion utilisateurs', '/admin/users'),
                  _item(context, Icons.business, 'Services hospitaliers', '/admin/services'),
                  _item(context, Icons.account_balance, 'Budgets', '/admin/budgets'),
                  _item(context, Icons.insert_chart, 'Rapports', '/admin/reports', badge: 1),
                  _item(context, Icons.history, 'Journal d’audit', '/admin/audit'),
                  _item(context, Icons.settings, 'Paramètres système', '/admin/settings'),
                ],
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 16, top: 8),
            child: _item(context, Icons.logout, 'Déconnexion', '/login'),
          ),
        ],
      ),
    );
  }
}
