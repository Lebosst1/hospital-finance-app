import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/services_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sejours_screen.dart';
import 'screens/patients_screen.dart';
import 'screens/previsions_screen.dart';
import 'screens/alertes_screen.dart';
import 'screens/finance_screen.dart';
import 'services/api_service.dart';
// Admin screens
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_services_screen.dart';
import 'screens/admin/admin_budgets_screen.dart';
import 'screens/admin/admin_alertes_screen.dart';
import 'screens/admin/admin_reports_screen.dart';
import 'screens/admin/admin_settings_screen.dart';
import 'screens/admin/admin_audit_screen.dart';

void main() {
  runApp(const HospitalFinanceApp());
}


class MyLocaleChanger extends InheritedWidget {
  final void Function(Locale) changeLocale;
  final Locale locale;
  const MyLocaleChanger({required this.changeLocale, required this.locale, required Widget child, Key? key}) : super(key: key, child: child);
  static MyLocaleChanger? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<MyLocaleChanger>();
  @override
  bool updateShouldNotify(MyLocaleChanger oldWidget) => locale != oldWidget.locale;
}

class HospitalFinanceApp extends StatefulWidget {
  const HospitalFinanceApp({super.key});
  @override
  State<HospitalFinanceApp> createState() => _HospitalFinanceAppState();
}

class _HospitalFinanceAppState extends State<HospitalFinanceApp> {

  Locale _locale = const Locale('fr');

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    // ignore: import_of_legacy_library_into_null_safe
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('lang') ?? 'fr';
    setState(() {
      _locale = Locale(lang);
    });
  }

  Future<void> _changeLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyLocaleChanger(
      changeLocale: _changeLocale,
      locale: _locale,
      child: MaterialApp(
        title: 'Hospital Finance Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFFFFF5FF),
        ),
        locale: _locale,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizationsDelegate(),
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
        ],
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
          '/admin': (context) => const AdminDashboardScreen(),
          '/admin/users': (context) => const AdminUsersScreen(),
          '/admin/services': (context) => const AdminServicesScreen(),
          '/admin/budgets': (context) => const AdminBudgetsScreen(),
          '/admin/alertes': (context) => const AdminAlertesScreen(),
          '/admin/reports': (context) => const AdminReportsScreen(),
          '/admin/settings': (context) => const AdminSettingsScreen(),
          '/admin/audit': (context) => const AdminAuditScreen(),
        },
      ),
    );
  }
}

/// Petit widget réutilisable pour le menu latéral

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.currentRoute, this.isAdmin = false});

  final String currentRoute;
  final bool isAdmin;

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
          if (isAdmin) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Dashboard'),
              selected: currentRoute == '/admin',
              onTap: () => go('/admin'),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Gestion utilisateurs'),
              selected: currentRoute == '/admin/users',
              onTap: () => go('/admin/users'),
            ),
            ListTile(
              leading: const Icon(Icons.local_hospital),
              title: const Text('Gestion services'),
              selected: currentRoute == '/admin/services',
              onTap: () => go('/admin/services'),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Budgets & seuils'),
              selected: currentRoute == '/admin/budgets',
              onTap: () => go('/admin/budgets'),
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Gestion alertes'),
              selected: currentRoute == '/admin/alertes',
              onTap: () => go('/admin/alertes'),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Rapports & exports'),
              selected: currentRoute == '/admin/reports',
              onTap: () => go('/admin/reports'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres système'),
              selected: currentRoute == '/admin/settings',
              onTap: () => go('/admin/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Journal d\'audit'),
              selected: currentRoute == '/admin/audit',
              onTap: () => go('/admin/audit'),
            ),
          ],
        ],
      ),
    );
  }
}
