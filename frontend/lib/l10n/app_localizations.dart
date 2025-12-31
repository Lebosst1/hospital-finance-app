import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const _localizedValues = <String, Map<String, String>>{
    'fr': {
      'dashboard': 'Tableau de bord',
      'users': 'Utilisateurs',
      'services': 'Services hospitaliers',
      'budgets': 'Budgets',
      'alertes': 'Alertes',
      'reports': 'Rapports',
      'settings': 'Paramètres',
      'audit': 'Journal d’audit',
      'logout': 'Déconnexion',
      'admin_dashboard': 'Espace Administrateur',
      'welcome_admin': 'Bienvenue, Administrateur',
      'admin': 'Administration',
      'language': 'Langue',
    },
    'en': {
      'dashboard': 'Dashboard',
      'users': 'Users',
      'services': 'Hospital Services',
      'budgets': 'Budgets',
      'alertes': 'Alerts',
      'reports': 'Reports',
      'settings': 'Settings',
      'audit': 'Audit Log',
      'logout': 'Logout',
      'admin_dashboard': 'Admin Area',
      'welcome_admin': 'Welcome, Admin',
      'admin': 'Administration',
      'language': 'Language',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
