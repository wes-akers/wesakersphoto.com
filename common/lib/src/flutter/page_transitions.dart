import 'package:flutter/material.dart';

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    return _NoPageTransition(
      animation: animation,
      child: child,
    );
  }
}

class _NoPageTransition extends StatelessWidget {
  const _NoPageTransition({
    required this.child,
    required this.animation,
  });

  final Widget? child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => animation.isCompleted
      ? child ?? const SizedBox.shrink()
      : const SizedBox.shrink();
}
