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
        home: _flavorBanner(child: const MyHomePage()),
      ),
    );
  }

  Widget _flavorBanner({required Widget child, bool show = true}) => show
      ? Banner(
          location: BannerLocation.topStart,
          message: F.name,
          color: Colors.green.withAlpha(150),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 1,
          ),
          textDirection: TextDirection.ltr,
          child: child,
        )
      : Container(child: child);
}

class DraggableScrollableSheetExample extends StatefulWidget {
  const DraggableScrollableSheetExample({super.key});

  @override
  State<DraggableScrollableSheetExample> createState() =>
      _DraggableScrollableSheetExampleState();
}

class _DraggableScrollableSheetExampleState
    extends State<DraggableScrollableSheetExample> {
  // This variable is used to restore the draggable sheet drag position
  // for the purpose of handling over-dragging beyond bounds when
  // the dragging mouse pointer re-enters the window on web and desktop platforms.
  double _dragPosition = 0.5;
  late double _sheetPosition = _dragPosition;
  final minChildSize = 0.25;
  final maxChildSize = 1.0;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('DraggableScrollableSheet Sample')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double viewHeight = constraints.maxHeight;
      
          return DraggableScrollableSheet(
            initialChildSize: _sheetPosition,
            builder: (BuildContext context, ScrollController scrollController) {
              return ColoredBox(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Grabber(
                      onVerticalDragUpdate: (DragUpdateDetails details) {
                        setState(() {
                          _dragPosition -= details.delta.dy / viewHeight;
                          _sheetPosition = _dragPosition.clamp(
                              minChildSize,
                              maxChildSize,
                            );
                          });
                        },
                      ),
                    Flexible(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: 25,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(
                              'Item $index',
                              style: TextStyle(color: colorScheme.surface),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// A draggable widget that accepts vertical drag gestures.
///
/// This is typically only used in desktop or web platforms.
class Grabber extends StatelessWidget {
  const Grabber({super.key, required this.onVerticalDragUpdate});

  final ValueChanged<DragUpdateDetails> onVerticalDragUpdate;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      child: Container(
        width: double.infinity,
        color: colorScheme.onSurface,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            width: 32.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
