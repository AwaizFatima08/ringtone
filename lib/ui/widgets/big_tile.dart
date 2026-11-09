import 'package:easyringtone/ui/theme.dart';
import 'package:flutter/material.dart';

/// A full-width button with a coloured icon, a big label and an optional line under it.
/// The main way to move around the app.
class BigTile extends StatelessWidget {
  const BigTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = this.subtitle;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 88),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: color,
                  child: Icon(icon, size: 34, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: theme.textTheme.titleLarge),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  size: 36,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
