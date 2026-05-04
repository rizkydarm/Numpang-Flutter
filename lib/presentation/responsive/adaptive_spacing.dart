import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// Adaptive spacing values that scale with screen size
class AdaptiveSpacing {
  static EdgeInsets padding(BuildContext context) {
    final type = context.screenType;
    switch (type) {
      case ScreenType.compact:
        return const EdgeInsets.all(16);
      case ScreenType.medium:
        return const EdgeInsets.all(24);
      case ScreenType.expanded:
        return const EdgeInsets.all(32);
    }
  }

  static EdgeInsets horizontalPadding(BuildContext context) {
    final type = context.screenType;
    switch (type) {
      case ScreenType.compact:
        return const EdgeInsets.symmetric(horizontal: 16);
      case ScreenType.medium:
        return const EdgeInsets.symmetric(horizontal: 24);
      case ScreenType.expanded:
        return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  static double cardPadding(BuildContext context) {
    final type = context.screenType;
    switch (type) {
      case ScreenType.compact:
        return 12;
      case ScreenType.medium:
        return 16;
      case ScreenType.expanded:
        return 20;
    }
  }

  static double gap(BuildContext context) {
    final type = context.screenType;
    switch (type) {
      case ScreenType.compact:
        return 8;
      case ScreenType.medium:
        return 12;
      case ScreenType.expanded:
        return 16;
    }
  }

  static double bottomSheetSideMargin(ScreenType type) {
    switch (type) {
      case ScreenType.compact:
        return 0;
      case ScreenType.medium:
        return 0;
      case ScreenType.expanded:
        return 24;
    }
  }
}
