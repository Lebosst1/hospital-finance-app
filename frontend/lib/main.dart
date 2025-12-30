// lib/main.dart
import 'package:flutter/material.dart';

import 'screens/services_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sejours_screen.dart';
import 'screens/patients_screen.dart';
import 'screens/previsions_screen.dart';
import 'screens/alertes_screen.dart';
import 'screens/finance_screen.dart';

void main() {
  runApp(const HospitalFinanceApp());
}

class HospitalFinanceApp extends StatelessWidget {
  const HospitalFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital Finance Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFFFF5FF),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/services': (context) => const ServicesScreen(),
        '/sejours': (context) => const SejoursScreen(),
        '/patients': (context) => const PatientsScreen(),
        '/previsions': (context) => const PrevisionsScreen(),
        '/alertes': (context) => const AlertesScreen(),
        '/finance': (context) => const FinanceScreen(),
      },
    );
  }
}

/// Petit widget réutilisable pour le menu latéral
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    void go(String route) {
      if (route == currentRoute) {
        Navigator.pop(context);
        return;
      }
      Navigator.pushReplacementNamed(context, route);
    }

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Center(
              child: Text(
                'Hospital Finance',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Services'),
            selected: currentRoute == '/dashboard',
            onTap: () => go('/dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.bed),
            title: const Text('Séjours'),
            selected: currentRoute == '/sejours',
            onTap: () => go('/sejours'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Patients'),
            selected: currentRoute == '/patients',
            onTap: () => go('/patients'),
          ),
          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('Prévisions'),
            selected: currentRoute == '/previsions',
            onTap: () => go('/previsions'),
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber),
            title: const Text('Alertes'),
            selected: currentRoute == '/alertes',
            onTap: () => go('/alertes'),
          ),
        ],
      ),
    );
  }
}
