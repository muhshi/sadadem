import 'package:flutter/material.dart';

/// Custom page route with a smooth slide + subtle fade transition.
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SmoothPageRoute({
    required this.child,
    super.settings,
    Duration transitionDuration = const Duration(milliseconds: 260),
    Duration reverseTransitionDuration = const Duration(milliseconds: 220),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.06, 0.0);
            const end = Offset.zero;
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(begin: begin, end: end).animate(curve),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
                child: child,
              ),
            );
          },
        );
}
