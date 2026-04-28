import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InjectionContainer extends StatelessWidget {
  final Widget child;

  const InjectionContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add providers here as BLoCs are implemented
        // Example:
        // ChangeNotifierProvider(create: (_) => DestinationBloc()),
      ],
      child: child,
    );
  }
}
