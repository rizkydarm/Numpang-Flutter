import 'package:flutter/material.dart';

/// Breakpoint constants per AGENTS.md
abstract class AppBreakpoints {
  static const double compact = 600; // Phone
  static const double medium = 1024; // Tablet/Desktop boundary
}

/// Screen type based on available width
enum ScreenType {
  compact, // < 600px (phone)
  medium, // 600-1024px (tablet)
  expanded, // >= 1024px (desktop)
}

/// Get screen type from width
ScreenType getScreenType(double width) {
  if (width >= AppBreakpoints.medium) return ScreenType.expanded;
  if (width >= AppBreakpoints.compact) return ScreenType.medium;
  return ScreenType.compact;
}

/// Extension for quick screen type access from BuildContext
extension ScreenTypeExtension on BuildContext {
  ScreenType get screenType {
    final width = MediaQuery.sizeOf(this).width;
    return getScreenType(width);
  }

  bool get isCompact => screenType == ScreenType.compact;
  bool get isMedium => screenType == ScreenType.medium;
  bool get isExpanded => screenType == ScreenType.expanded;
}

/// Responsive builder widget that rebuilds when screen size changes
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.builder,
    super.key,
  });

  final Widget Function(BuildContext context, ScreenType screenType) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = getScreenType(constraints.maxWidth);
        return builder(context, screenType);
      },
    );
  }
}

/// Widget that shows different children based on screen type
class ResponsiveWidget extends StatelessWidget {
  const ResponsiveWidget({
    required this.compact,
    this.medium,
    this.expanded,
    super.key,
  });

  final Widget compact;
  final Widget? medium;
  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        switch (screenType) {
          case ScreenType.compact:
            return compact;
          case ScreenType.medium:
            return medium ?? compact;
          case ScreenType.expanded:
            return expanded ?? medium ?? compact;
        }
      },
    );
  }
}

/// Bottom sheet constraints per screen type
class BottomSheetConstraints {
  static const double maxWidthCompact = double.infinity;
  static const double maxWidthMedium = 500;
  static const double maxWidthExpanded = 500;

  static AlignmentGeometry alignment(ScreenType type) {
    switch (type) {
      case ScreenType.compact:
        return Alignment.bottomCenter;
      case ScreenType.medium:
        return Alignment.bottomCenter;
      case ScreenType.expanded:
        return Alignment.bottomLeft;
    }
  }

  static double maxWidth(ScreenType type) {
    switch (type) {
      case ScreenType.compact:
        return maxWidthCompact;
      case ScreenType.medium:
        return maxWidthMedium;
      case ScreenType.expanded:
        return maxWidthExpanded;
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
