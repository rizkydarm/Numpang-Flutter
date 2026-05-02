import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numpang_app/core/theme/app_theme.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_bloc.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_event.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_state.dart';
import 'package:numpang_app/presentation/widgets/destination/delete_confirmation_dialog.dart';
import 'package:numpang_app/presentation/widgets/destination/destination_list_item.dart';

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
      builder: (context, scrollController) {
        return DecoratedBox(
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
              return CustomScrollView(
                controller: scrollController,
                slivers: [
                  // Drag Handle
                  SliverToBoxAdapter(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                            ? AppColors.textTertiaryDark.withValues(
                                alpha: 0.5,
                              )
                            : AppColors.textTertiary.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        height: 4,
                        width: 40,
                      ),
                    ),
                  ),
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          Text(
                            state.destinations.isEmpty
                              ? 'No destinations'
                              : '${state.destinations.length} ${state.destinations.length == 1 ? 'place' : 'places'} saved',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Content
                  if (state.isLoading && state.destinations.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 24),
                      sliver: SliverList.builder(
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
