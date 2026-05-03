import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:numpang_app/app.dart';
import 'package:numpang_app/data/models/recent_search_model.dart';
import 'package:numpang_app/flavors.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await dotenv.load();

      await Hive.initFlutter();
      Hive.registerAdapter(RecentSearchModelAdapter());
      await Hive.openBox<RecentSearchModel>('recent_searches');

      const flavor = String.fromEnvironment(
        'appFlavor',
        defaultValue: 'dev',
      );
      F.appFlavor = Flavor.values.firstWhere(
        (element) => element.name == flavor,
      );

      runApp(const App());
    },
    (error, stack) {
      debugPrint('Uncaught error: $error');
      debugPrint(stack.toString());
    },
  );
}
