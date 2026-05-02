import 'package:flutter/material.dart';
import 'package:numpang_app/core/theme/app_theme.dart';

class EmptyDestinationsView extends StatelessWidget {
  const EmptyDestinationsView({super.key, this.onAddTap});
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        // If too small (collapsed sheet), show minimal text only
        if (constraints.maxHeight < 100) {
          return Center(
            child: Text(
              'No destinations',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          );
        }

        // Full empty state view
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_off_outlined,
                    size: 40,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No destinations yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap on the map to add your first destination',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                if (onAddTap != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onAddTap,
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Add Destination'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
