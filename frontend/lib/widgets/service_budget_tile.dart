import 'package:flutter/material.dart';

class ServiceBudgetTile extends StatelessWidget {
  final String name;
  final double allocated;
  final double spent;
  final bool aiFlag;
  final VoidCallback? onMenu;

  const ServiceBudgetTile({
    super.key,
    required this.name,
    required this.allocated,
    required this.spent,
    this.aiFlag = false,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = allocated <= 0 ? 0 : (spent / allocated).clamp(0, 1);
    final remaining = (allocated - spent);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (aiFlag)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: theme.colorScheme.tertiaryContainer,
                    ),
                    child: Text(
                      "IA",
                      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                PopupMenuButton<String>(
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "details", child: Text("Détails")),
                    PopupMenuItem(value: "edit", child: Text("Modifier budget")),
                    PopupMenuItem(value: "threshold", child: Text("Ajuster seuil")),
                  ],
                  onSelected: (v) => onMenu?.call(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "${allocated.toStringAsFixed(0)} DH • ${(pct * 100).toStringAsFixed(0)}% • reste ${remaining.toStringAsFixed(0)} DH",
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: pct.toDouble(), minHeight: 8),
            ),
          ],
        ),
      ),
    );
  }
}
