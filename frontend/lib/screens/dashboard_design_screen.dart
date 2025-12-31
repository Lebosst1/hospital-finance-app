import 'package:flutter/material.dart';
import 'quick_access_pager.dart';

class DashboardDesignScreen extends StatelessWidget {
  final bool isAdmin;
  final String userName;
  final int nbServices;
  final double totalMensuel;
  final double totalAnnuel;
  final bool isLoading;
  final VoidCallback onLogout;

  const DashboardDesignScreen({
    Key? key,
    required this.isAdmin,
    required this.userName,
    required this.nbServices,
    required this.totalMensuel,
    required this.totalAnnuel,
    required this.isLoading,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0, left: 12, right: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                gradient: const LinearGradient(
                  colors: [Color(0xFFe0e7ff), Color(0xFFfdf6ff)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366f1).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.dashboard_customize_rounded, color: Color(0xFF6366f1), size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Hospital Finance Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF22223b))),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                isAdmin ? 'Espace administrateur' : 'Espace utilisateur',
                                style: TextStyle(fontSize: 13, color: isAdmin ? Colors.red.shade400 : Colors.blueGrey),
                              ),
                              if (isAdmin)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'ADMIN',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (userName.isNotEmpty)
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF6366f1).withOpacity(0.15),
                            child: Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366f1)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(userName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                        ],
                      ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: onLogout,
                      tooltip: 'Déconnexion',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFe0e7ff), Color(0xFFfdf6ff)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 80.0, left: 16, right: 16),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Accès rapide sous forme de PageView avec flèches
                    SizedBox(
                      height: 160,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.45),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.white.withOpacity(0.18)),
                          ),
                          child: QuickAccessPager(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    // Un petit résumé KPIs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildKpiCard(
                            title: 'Nombre de services',
                            value: nbServices.toString(),
                            icon: Icons.local_hospital,
                            color: const Color(0xFF6366f1),
                          ),
                          const SizedBox(width: 24),
                          _buildKpiCard(
                            title: 'Budget mensuel total',
                            value: '${totalMensuel.toStringAsFixed(0)} DH',
                            icon: Icons.calendar_view_month,
                            color: const Color(0xFF10b981),
                          ),
                          const SizedBox(width: 24),
                          _buildKpiCard(
                            title: 'Budget annuel total',
                            value: '${totalAnnuel.toStringAsFixed(0)} DH',
                            icon: Icons.calendar_today,
                            color: const Color(0xFFf59e42),
                          ),
                        ],
                      ),
                    ),
                    // On peut ajouter d'autres widgets ici si besoin
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({required String title, required String value, required IconData icon, Color color = const Color(0xFF6366f1)}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.18), width: 1.2),
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: color.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
