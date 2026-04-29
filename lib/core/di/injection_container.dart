import 'package:flutter/material.dart';
import 'package:numpang_app/flavors.dart';
import 'package:provider/provider.dart';

class InjectionContainer extends StatelessWidget {
  final Widget child;

  const InjectionContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Flavor>.value(value: F.appFlavor),
      ],
      child: child,
    );
  }
}
