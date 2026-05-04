import 'package:flutter/material.dart';
import 'package:numpang_app/core/di/injection_container.dart';
import 'package:numpang_app/core/theme/app_theme.dart';
import 'package:numpang_app/flavors.dart';
import 'package:numpang_app/presentation/screens/map/map_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return InjectionContainer(
      child: MaterialApp(
        title: F.title,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const MyHomePage(),
      ),
    );
  }
}

