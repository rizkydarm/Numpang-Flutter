import 'package:flutter/material.dart';
import 'package:numpang_app/core/theme/app_theme.dart';

class DeleteConfirmationDialog extends StatelessWidget {

  const DeleteConfirmationDialog({
    required this.destinationName, super.key,
  });
  final String destinationName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.delete_forever,
            color: Colors.red.shade400,
          ),
          const SizedBox(width: 12),
          Text(
            'Delete Destination?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Text(
        '"$destinationName" will be permanently deleted.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  /// Shows the dialog and returns true if confirmed, false otherwise
  static Future<bool> show(BuildContext context, String destinationName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        destinationName: destinationName,
      ),
    );
    return result ?? false;
  }
}
