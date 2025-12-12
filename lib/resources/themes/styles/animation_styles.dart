import 'package:flutter/material.dart';

/// Animation styles and constants for TaskFlow app
class AnimationStyles {
  // Duration constants
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration verySlow = Duration(milliseconds: 500);
  
  // Curve constants
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  
  // Common animations
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Duration defaultDuration = Duration(milliseconds: 250);
  
  // Page transitions
  static Widget slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
          CurveTween(curve: defaultCurve),
        ),
      ),
      child: child,
    );
  }
  
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation.drive(
        CurveTween(curve: defaultCurve),
      ),
      child: child,
    );
  }
  
  static Widget scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: animation.drive(
        Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: elasticOut),
        ),
      ),
      child: FadeTransition(
        opacity: animation.drive(
          CurveTween(curve: easeOut),
        ),
        child: child,
      ),
    );
  }
  
  // Widget animations
  static Widget animatedContainer({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      child: child,
    );
  }
  
  static Widget animatedOpacity({
    required Widget child,
    required double opacity,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
  
  static Widget animatedScale({
    required Widget child,
    required double scale,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return AnimatedScale(
      scale: scale,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
  
  // List animations
  static Widget listItemAnimation({
    required Widget child,
    required Animation<double> animation,
    int index = 0,
  }) {
    return SlideTransition(
      position: animation.drive(
        Tween(
          begin: Offset(0.0, 0.3 + (index * 0.1)),
          end: Offset.zero,
        ).chain(CurveTween(curve: easeOut)),
      ),
      child: FadeTransition(
        opacity: animation.drive(
          CurveTween(curve: easeOut),
        ),
        child: child,
      ),
    );
  }
  
  // Staggered animations for lists
  static Duration getStaggeredDelay(int index, {Duration baseDelay = const Duration(milliseconds: 50)}) {
    return Duration(milliseconds: baseDelay.inMilliseconds * index);
  }
}

/// Extension methods for easier animation usage
extension AnimationExtensions on Widget {
  Widget fadeIn({
    Duration duration = AnimationStyles.defaultDuration,
    Curve curve = AnimationStyles.defaultCurve,
    double opacity = 1.0,
  }) {
    return AnimationStyles.animatedOpacity(
      opacity: opacity,
      duration: duration,
      curve: curve,
      child: this,
    );
  }
  
  Widget scale({
    Duration duration = AnimationStyles.defaultDuration,
    Curve curve = AnimationStyles.defaultCurve,
    double scale = 1.0,
  }) {
    return AnimationStyles.animatedScale(
      scale: scale,
      duration: duration,
      curve: curve,
      child: this,
    );
  }
}