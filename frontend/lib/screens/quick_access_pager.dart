import 'package:flutter/material.dart';

class QuickAccessPager extends StatefulWidget {
  @override
  State<QuickAccessPager> createState() => QuickAccessPagerState();
}

class QuickAccessPagerState extends State<QuickAccessPager> {
  final PageController _controller = PageController(viewportFraction: 0.55);
  int _currentPage = 0;

  final List<_QuickAccessItem> _items = [
    _QuickAccessItem(
      icon: Icons.local_hospital,
      color: Colors.indigo,
      label: 'Services',
      route: '/services',
    ),
    _QuickAccessItem(
      icon: Icons.bar_chart,
      color: Colors.deepPurple,
      label: 'Analyses financières',
      route: '/finance',
    ),
    _QuickAccessItem(
      icon: Icons.people,
      color: Colors.teal,
      label: 'Patients',
      route: '/patients',
    ),
    _QuickAccessItem(
      icon: Icons.warning,
      color: Colors.red,
      label: 'Alertes',
      route: '/alertes',
    ),
  ];

  void _goTo(int page) {
    if (page < 0 || page >= _items.length) return;
    _controller.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left, size: 32),
          onPressed: _currentPage > 0 ? () => _goTo(_currentPage - 1) : null,
        ),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: _items.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) {
              final item = _items[i];
              return Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, item.route),
                  child: Card(
                    elevation: 6,
                    color: item.color.withOpacity(0.09),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    child: SizedBox(
                      width: 170,
                      height: 130,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item.icon, size: 54, color: item.color),
                          const SizedBox(height: 14),
                          Text(item.label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: item.color)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right, size: 32),
          onPressed: _currentPage < _items.length - 1 ? () => _goTo(_currentPage + 1) : null,
        ),
      ],
    );
  }
}

class _QuickAccessItem {
  final IconData icon;
  final Color color;
  final String label;
  final String route;
  const _QuickAccessItem({required this.icon, required this.color, required this.label, required this.route});
}