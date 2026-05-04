import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/entities/place_suggestion.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_bloc.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_event.dart';
import 'package:numpang_app/presentation/bloc/map_bloc.dart';
import 'package:numpang_app/presentation/bloc/map_event.dart';
import 'package:numpang_app/presentation/bloc/search_bloc.dart';
import 'package:numpang_app/presentation/bloc/search_event.dart';
import 'package:numpang_app/presentation/bloc/search_state.dart';
import 'package:numpang_app/presentation/widgets/search/autocomplete_dropdown.dart';

class FloatingSearchBar extends StatefulWidget {
  const FloatingSearchBar({super.key});

  @override
  State<FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<FloatingSearchBar> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _isDropdownVisible = false;

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    context.read<SearchBloc>().add(QueryChanged(query));
    setState(() {
      _isDropdownVisible = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: Color(0xFF9B9079)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Search here',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF9B9079),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: _onQueryChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isDropdownVisible) const SizedBox(height: 8),
          if (_isDropdownVisible)
            BlocBuilder<SearchBloc, SearchState>(
              buildWhen: (p, n) =>
                  p.suggestions != n.suggestions ||
                  p.isLoading != n.isLoading ||
                  p.error != n.error,
              builder: (context, state) {
                if (state.error != null) {
                  debugPrint('[FloatingSearchBar] Error: ${state.error}');
                  return _buildErrorWidget(context, state.error!);
                }
                return AutocompleteDropdown(
                  suggestions: state.suggestions,
                  isLoading: state.isLoading,
                  onSuggestionSelected: (suggestion) {
                    _controller.clear();
                    _focusNode.unfocus();
                    setState(() => _isDropdownVisible = false);
                    _showPlaceDialog(context, suggestion);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  void _showPlaceDialog(BuildContext context, PlaceSuggestion suggestion) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final destinationBloc = context.read<DestinationBloc>();
    final mapBloc = context.read<MapBloc>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            suggestion.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            suggestion.address,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                final point = LatLng(suggestion.latitude, suggestion.longitude);
                destinationBloc.add(
                  AddDestination(
                    name: suggestion.name,
                    address:
                        '${suggestion.latitude.toStringAsFixed(4)}, ${suggestion.longitude.toStringAsFixed(4)}',
                    position: point,
                  ),
                );
                mapBloc.add(TapOnMap(point, address: suggestion.name));
                Navigator.of(dialogContext).pop();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFCA28),
                foregroundColor: const Color(0xFF705600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, Failure error) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              size: 16,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Search failed. Please try again.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              color: theme.colorScheme.onErrorContainer,
              onPressed: () {
                context.read<SearchBloc>().add(const ClearSearch());
                setState(() => _isDropdownVisible = false);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
      ),
    );
  }
}
