import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/core/theme/app_theme.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_bloc.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_event.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_state.dart';
import 'package:numpang_app/presentation/widgets/destination/add_destination_fab.dart';
import 'package:numpang_app/presentation/widgets/destination/delete_confirmation_dialog.dart';
import 'package:numpang_app/presentation/widgets/destination/destination_list_item.dart';
import 'package:numpang_app/presentation/widgets/destination/empty_destinations_view.dart';

class DestinationBottomSheet extends StatefulWidget {
  const DestinationBottomSheet({
    super.key,
    this.onDestinationSelected,
    this.onAddDestination,
  });
  final VoidCallback? onDestinationSelected;
  final VoidCallback? onAddDestination;

  @override
  State<DestinationBottomSheet> createState() => _DestinationBottomSheetState();
}

class _DestinationBottomSheetState extends State<DestinationBottomSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  static const double _collapsedSize = 0.25;
  static const double _halfSize = 0.5;
  static const double _fullSize = 1.0;

  @override
  void initState() {
    super.initState();
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
      // snapAnimationDuration: const Duration(milliseconds: 300),
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // Drag Handle - always visible, minimal height
                  GestureDetector(
                    onVerticalDragEnd: (_) {
                      final currentSize = _controller.size;
                      final target = currentSize < (_halfSize + _collapsedSize) / 2
                          ? _collapsedSize
                          : currentSize < (_fullSize + _halfSize) / 2
                              ? _halfSize
                              : _fullSize;
                      _controller.animateTo(
                        target,
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                    onVerticalDragUpdate: (details) {
                      if (!_controller.isAttached) return;
                      final currentSize = _controller.size;
                      final delta = details.delta.dy;
                      final newSize =
                          currentSize - delta / constraints.maxHeight;
                      _controller.animateTo(
                        newSize.clamp(_collapsedSize, _fullSize),
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutExpo,
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Center(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.textTertiaryDark.withValues(alpha: 0.5) : AppColors.textTertiary.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const SizedBox(width: 40, height: 4),
                              ),
                            ),
                        
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  

                  // Content - must always have a scrollable widget
                  // so DraggableScrollableSheet can track gestures
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
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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
                          // Always allow scrolling so sheet can expand
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: state.destinations.length,
                          itemBuilder: (context, index) {
                            final destination = state.destinations[index];
                            return DestinationListItem(
                              destination: destination,
                              isSelected:
                                  state.selectedDestination?.id ==
                                  destination.id,
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
              );
            },
          ),
        );
      },
    );
  }
}
