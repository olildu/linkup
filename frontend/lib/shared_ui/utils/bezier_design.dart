import 'dart:math';
import 'package:flutter/material.dart';

class RPSCustomPainter extends CustomPainter {
  final double waveShift;
  RPSCustomPainter(this.waveShift);

  @override
  void paint(Canvas canvas, Size size) {
    double ripple(double y, double xMultiplier) {
      return y + 10 * sin(waveShift + xMultiplier);
    }

    // First shape
    Paint paintFill0 = Paint()
      ..color = const Color.fromARGB(255, 0, 214, 207)
      ..style = PaintingStyle.fill;

    Path path_0 = Path();
    path_0.moveTo(0, 0);

    path_0.quadraticBezierTo(
      size.width * 0.3307116,
      ripple(size.height * 0.0356541, 1),
      size.width * 0.3285401,
      ripple(size.height * 0.1445626, 2),
    );

    path_0.cubicTo(
      size.width * 0.3245802,
      ripple(size.height * 0.2340802, 3),
      size.width * 0.4382919,
      ripple(size.height * 0.2537074, 4),
      size.width * 0.5181276,
      ripple(size.height * 0.2720557, 5),
    );

    path_0.cubicTo(
      size.width * 0.6383284,
      ripple(size.height * 0.3002732, 6),
      size.width * 0.7132845,
      ripple(size.height * 0.2500377, 7),
      size.width * 0.7237334,
      ripple(size.height * 0.4323117, 8),
    );

    path_0.quadraticBezierTo(
      size.width * 0.7456787,
      ripple(size.height * 0.5768743, 9),
      size.width,
      ripple(size.height * 0.5517843, 10),
    );

    path_0.lineTo(size.width, 0);
    path_0.close();

    canvas.drawPath(path_0, paintFill0);

    // Second shape
    Paint paintFill1 = Paint()
      ..color = const Color.fromARGB(255, 0, 214, 207)
      ..style = PaintingStyle.fill;

    Path path_1 = Path();
    path_1.moveTo(0, ripple(size.height * 0.3557908, 11));

    path_1.quadraticBezierTo(
      size.width * 0.3245802,
      ripple(size.height * 0.4625169, 12),
      size.width * 0.2930802,
      ripple(size.height * 0.5662962, 13),
    );

    path_1.cubicTo(
      size.width * 0.2600985,
      ripple(size.height * 0.6890215, 14),
      size.width * 0.6284159,
      ripple(size.height * 0.5886200, 15),
      size.width * 0.6317371,
      ripple(size.height * 0.7669463, 16),
    );

    path_1.cubicTo(
      size.width * 0.6709013,
      ripple(size.height * 0.8956904, 17),
      size.width * 0.9033064,
      ripple(size.height * 0.9417836, 18),
      size.width,
      ripple(size.height * 1.0058776, 19),
    );

    path_1.lineTo(size.width, size.height);
    path_1.lineTo(0, size.height);

    path_1.close();

    canvas.drawPath(path_1, paintFill1);
  }

  @override
  bool shouldRepaint(covariant RPSCustomPainter oldDelegate) => true;
}
