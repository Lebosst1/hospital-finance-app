import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class AdminAuditScreen extends StatelessWidget {
  const AdminAuditScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal d\'audit')),
      drawer: AppDrawer(isAdmin: true, currentRoute: '/admin/audit'),
      body: Center(
        child: Text('Qui a fait quoi, quand, sur quoi...', style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
