import 'package:flutter/material.dart';

import 'package:numpang_app/app.dart';
import 'package:numpang_app/flavors.dart';

void main() {
  const flavor = String.fromEnvironment(
    'appFlavor',
    defaultValue: 'dev',
  );
  F.appFlavor = Flavor.values.firstWhere((element) => element.name == flavor);

  runApp(const App());
}
