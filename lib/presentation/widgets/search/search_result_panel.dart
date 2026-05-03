import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numpang_app/presentation/bloc/search_bloc.dart';
import 'package:numpang_app/presentation/bloc/search_event.dart';
import 'package:numpang_app/presentation/bloc/search_state.dart';

class SearchResultPanel extends StatelessWidget {
  const SearchResultPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      buildWhen: (p, n) =>
          p.selectedSuggestion != n.selectedSuggestion ||
          p.resultPosition != n.resultPosition ||
          p.resultAddress != n.resultAddress,
      builder: (context, state) {
        if (state.selectedSuggestion == null) return const SizedBox.shrink();

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Positioned(
          bottom: 80,
          left: 16,
          right: 16,
          child: SafeArea(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.selectedSuggestion!.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.resultAddress ??
                                    state.selectedSuggestion!.address,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          color: colorScheme.onSurfaceVariant,
                          onPressed: () {
                            context.read<SearchBloc>().add(const ClearSearch());
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          context.read<SearchBloc>().add(
                            SearchSubmitted(state.selectedSuggestion!.name),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add to Destinations'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCA28),
                          foregroundColor: const Color(0xFF705600),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
