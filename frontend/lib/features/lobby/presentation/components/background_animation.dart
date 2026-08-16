import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:linkup/shared_ui/utils/bezier_design.dart';

class BackgroundAnimation extends StatelessWidget {
  final Animation<double> animation;
  final Widget? child;
  final bool blur;

  const BackgroundAnimation({
    super.key,
    required this.animation,
    this.child,
    this.blur = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: blur ? 6.0 : 0),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOut,
          builder: (context, blurValue, _) {
            return Stack(
              children: [
                Container(color: Colors.black),
                Positioned.fill(
                  child: CustomPaint(
                    painter: RPSCustomPainter(animation.value * 2 * math.pi),
                  ),
                ),
                if (blurValue > 0)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: blurValue,
                        sigmaY: blurValue,
                      ),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                if (child != null) child!,
              ],
            );
          },
        );
      },
    );
  }
}
