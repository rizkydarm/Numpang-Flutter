import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/destination/destination_bloc.dart';
import '../../bloc/destination/destination_event.dart';
import '../../bloc/destination/destination_state.dart';
import 'add_destination_fab.dart';
import 'delete_confirmation_dialog.dart';
import 'destination_list_item.dart';
import 'empty_destinations_view.dart';

class DestinationBottomSheet extends StatefulWidget {
  final VoidCallback? onDestinationSelected;
  final VoidCallback? onAddDestination;

  const DestinationBottomSheet({
    super.key,
    this.onDestinationSelected,
    this.onAddDestination,
  });

  @override
  State<DestinationBottomSheet> createState() => _DestinationBottomSheetState();
}

class _DestinationBottomSheetState extends State<DestinationBottomSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  static const double _collapsedSize = 0.12;
  static const double _halfSize = 0.5;
  static const double _fullSize = 0.9;

  void snapToExpanded() {
    _controller.animateTo(
      _halfSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void snapToFull() {
    _controller.animateTo(
      _fullSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void snapToCollapsed() {
    _controller.animateTo(
      _collapsedSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: _collapsedSize,
      minChildSize: _collapsedSize,
      maxChildSize: _fullSize,
      snap: true,
      snapSizes: const [_collapsedSize, _halfSize, _fullSize],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              GestureDetector(
                onTap: () {
                  final currentSize = _controller.size;
                  if (currentSize < _halfSize) {
                    snapToExpanded();
                  } else {
                    snapToCollapsed();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.textTertiaryDark.withOpacity(0.5)
                            : AppColors.textTertiary.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Destinations',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          BlocBuilder<DestinationBloc, DestinationState>(
                            builder: (context, state) {
                              final count = state.destinations.length;
                              return Text(
                                count == 0
                                    ? 'No destinations'
                                    : '$count ${count == 1 ? 'place' : 'places'} saved',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Add Button
                    AddDestinationFab(
                      onPressed: () async {
                        final name = await AddDestinationDialog.show(
                          context,
                          initialName: 'New Destination',
                        );
                        if (name != null && context.mounted) {
                          // Get current location as position
                          // For now, use Jakarta coordinates as default
                          context.read<DestinationBloc>().add(
                            AddDestination(
                              name: name,
                              address: 'Current Location',
                              position: const LatLng(-6.2088, 106.8456),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Content
              Expanded(
                child: BlocConsumer<DestinationBloc, DestinationState>(
                  listener: (context, state) {
                    if (state.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error!.message),
                          backgroundColor: Colors.red.shade700,
                          action: SnackBarAction(
                            label: 'Dismiss',
                            textColor: Colors.white,
                            onPressed: () {
                              context.read<DestinationBloc>().add(
                                const ClearDestinationError(),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.isLoading && state.destinations.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.destinations.isEmpty) {
                      return EmptyDestinationsView(
                        onAddTap: () async {
                          final name = await AddDestinationDialog.show(
                            context,
                            initialName: 'New Destination',
                          );
                          if (name != null && context.mounted) {
                            context.read<DestinationBloc>().add(
                              AddDestination(
                                name: name,
                                address: 'Current Location',
                                position: const LatLng(-6.2088, 106.8456),
                              ),
                            );
                          }
                        },
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: state.destinations.length,
                      itemBuilder: (context, index) {
                        final destination = state.destinations[index];
                        return DestinationListItem(
                          destination: destination,
                          isSelected:
                              state.selectedDestination?.id == destination.id,
                          onTap: () {
                            context.read<DestinationBloc>().add(
                              SelectDestination(destination),
                            );
                            widget.onDestinationSelected?.call();
                          },
                          onDelete: () async {
                            final confirmed =
                                await DeleteConfirmationDialog.show(
                                  context,
                                  destination.name,
                                );
                            if (confirmed && context.mounted) {
                              context.read<DestinationBloc>().add(
                                DeleteDestination(
                                  id: destination.id,
                                  name: destination.name,
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
