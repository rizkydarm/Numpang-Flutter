import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/entities/place_suggestion.dart';
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
                    context.read<SearchBloc>().add(
                      SuggestionSelected(suggestion),
                    );
                    _controller.clear();
                    _focusNode.unfocus();
                    setState(() => _isDropdownVisible = false);
                  },
                );
              },
            ),
        ],
      ),
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
