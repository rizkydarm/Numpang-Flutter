import 'package:flutter/material.dart';

import 'app.dart';
import 'flavors.dart';

void main() {
  const String flavor = String.fromEnvironment(
    'appFlavor',
    defaultValue: 'dev',
  );
  F.appFlavor = Flavor.values.firstWhere((element) => element.name == flavor);

  runApp(const App());
}
