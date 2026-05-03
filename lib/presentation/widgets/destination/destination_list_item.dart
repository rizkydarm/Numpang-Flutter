import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numpang_app/core/theme/app_theme.dart';
import 'package:numpang_app/domain/entities/destination.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_bloc.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_event.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_state.dart';

class DestinationListItem extends StatefulWidget {
  const DestinationListItem({
    required this.destination,
    required this.onTap,
    required this.onDelete,
    super.key,
    this.isSelected = false,
  });
  final Destination destination;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<DestinationListItem> createState() => _DestinationListItemState();
}

class _DestinationListItemState extends State<DestinationListItem> {
  @override
  void initState() {
    super.initState();
    _loadReverseGeocodedAddress();
  }

  void _loadReverseGeocodedAddress() {
    context.read<DestinationBloc>().add(
      LoadDestinationAddress(destinationId: widget.destination.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(widget.destination.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete(),
      confirmDismiss: (_) async {
        // Return true to confirm, false to cancel
        // Confirmation dialog handled by parent
        return true;
      },
      background: Align(
        alignment: Alignment.centerRight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.only(right: 24),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: widget.isSelected ? 2 : 0,
        color: widget.isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : (isDark ? AppColors.surfaceDark : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: widget.isSelected
              ? const BorderSide(color: AppColors.primary)
              : BorderSide.none,
        ),
        child: ListTile(
          onTap: widget.onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on, color: AppColors.primary),
          ),
          title: Text(
            widget.destination.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              _DestinationAddressText(
                destinationId: widget.destination.id,
                fallbackAddress: widget.destination.address,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(widget.destination.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Just now';
        }
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _DestinationAddressText extends StatelessWidget {
  const _DestinationAddressText({
    required this.destinationId,
    required this.fallbackAddress,
  });

  final String destinationId;
  final String fallbackAddress;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DestinationBloc, DestinationState>(
      buildWhen: (previous, current) =>
          previous.destinationAddresses[destinationId] !=
          current.destinationAddresses[destinationId],
      builder: (context, state) {
        final address = state.destinationAddresses[destinationId];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Text(
          address ?? fallbackAddress,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
