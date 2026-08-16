import 'package:flutter/material.dart';

class EventIntroAnimation extends StatefulWidget {
  final Widget child;
  final AlignmentGeometry alignment;

  const EventIntroAnimation({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
  });

  @override
  State<EventIntroAnimation> createState() => _EventIntroAnimationState();
}

class _EventIntroAnimationState extends State<EventIntroAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    double startDx;
    if (widget.alignment is Alignment) {
      final alignment = widget.alignment as Alignment;
      if (alignment.x > 0) {
        startDx = 0.2;
      } else if (alignment.x < 0) {
        startDx = -0.2;
      } else {
        startDx = 0.0;
      }
    } else {
      startDx = 0.0;
    }

    _slideAnimation = Tween<Offset>(
      begin: Offset(startDx, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
      ),
    );
  }
}
