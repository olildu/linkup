import 'package:flutter/material.dart';

class PageTransitionSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final bool reverse;
  final Widget Function(Widget, Animation<double>) transitionBuilder;

  const PageTransitionSwitcher({
    super.key,
    required this.child,
    required this.duration,
    required this.transitionBuilder,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: transitionBuilder,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: child,
    );
  }
}

class SharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final SharedAxisTransitionType transitionType;

  const SharedAxisTransition({
    super.key,
    required this.animation,
    required this.child,
    required this.transitionType,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );

    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
            child: child,
          ),
        );
      case SharedAxisTransitionType.vertical:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
            child: child,
          ),
        );
      case SharedAxisTransitionType.scaled:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curve),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
            child: child,
          ),
        );
    }
  }
}

enum SharedAxisTransitionType { horizontal, vertical, scaled }
