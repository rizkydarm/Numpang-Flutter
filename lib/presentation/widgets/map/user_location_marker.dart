import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class UserLocationMarker extends Marker {
  const UserLocationMarker({
    required super.point,
    double? width,
    double? height,
  }) : super(
          width: width ?? 20,
          height: height ?? 20,
          child: const _AnimatedUserLocationDot(),
        );
}

class _AnimatedUserLocationDot extends StatefulWidget {
  const _AnimatedUserLocationDot();

  @override
  State<_AnimatedUserLocationDot> createState() => _AnimatedUserLocationDotState();
}

class _AnimatedUserLocationDotState extends State<_AnimatedUserLocationDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1, end: 1.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.onPrimary.withAlpha(102),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withAlpha(102),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}