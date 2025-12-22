// lib/screens/user_dashboard_screen.dart

import 'package:flutter/material.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Utilisateur – Hospital Finance'),
      ),
      body: const Center(
        child: Text(
          'Bienvenue dans votre espace utilisateur.\n'
          'Ici, vous pourrez consulter les informations financières\n'
          'pertinentes pour votre service (séjours, coûts, etc.).',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
