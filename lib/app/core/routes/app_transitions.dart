import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppRouteTransitionType {
  fade,
  slideFromRight,
  slideFromLeft,
  scale,
}

CustomTransitionPage buildPageRoute({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  required AppRouteTransitionType transitionType,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (transitionType) {
        case AppRouteTransitionType.fade:
          return FadeTransition(opacity: animation, child: child);
        case AppRouteTransitionType.slideFromRight:
          final tween = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          );
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        case AppRouteTransitionType.slideFromLeft:
          final tween = Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          );
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        case AppRouteTransitionType.scale:
          final tween = Tween<double>(begin: 0.8, end: 1.0);
          final scaleAnimation = animation.drive(tween);
          return ScaleTransition(scale: scaleAnimation, child: child);
      }
    },
  );
}