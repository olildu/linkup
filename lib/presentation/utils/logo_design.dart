import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  final Animation<double> progress;
  final Color color;

  DrawingPainter(this.progress, this.color) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    // The bounding box of your path roughly (0,0) to (110,45)
    const double pathWidth = 110;
    const double pathHeight = 45;

    // Calculate scale to fit inside size (both width and height)
    final double scaleX = size.width / pathWidth;
    final double scaleY = size.height / pathHeight;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    // Calculate translation to center the path
    final double dx = (size.width - pathWidth * scale) / 2;
    final double dy = (size.height - pathHeight * scale) / 2;

    // Apply translate and scale before drawing the path
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    Path fullPath = Path();
    fullPath.moveTo(3.72, 1.4);
    fullPath.lineTo(3.72, 31);
    fullPath.lineTo(0.0800003, 31);
    fullPath.lineTo(0.0800003, 1.4);
    fullPath.lineTo(3.72, 1.4);
    fullPath.close();
    fullPath.moveTo(11.8038, 5.52);
    fullPath.cubicTo(11.1104, 5.52, 10.5238, 5.28, 10.0438, 4.8);
    fullPath.cubicTo(9.56375, 4.32, 9.32375, 3.73333, 9.32375, 3.04);
    fullPath.cubicTo(9.32375, 2.34667, 9.56375, 1.76, 10.0438, 1.28);
    fullPath.cubicTo(10.5238, 0.799999, 11.1104, 0.559999, 11.8038, 0.559999);
    fullPath.cubicTo(12.4704, 0.559999, 13.0304, 0.799999, 13.4838, 1.28);
    fullPath.cubicTo(13.9638, 1.76, 14.2038, 2.34667, 14.2038, 3.04);
    fullPath.cubicTo(14.2038, 3.73333, 13.9638, 4.32, 13.4838, 4.8);
    fullPath.cubicTo(13.0304, 5.28, 12.4704, 5.52, 11.8038, 5.52);
    fullPath.close();
    fullPath.moveTo(13.5638, 9.08);
    fullPath.lineTo(13.5638, 31);
    fullPath.lineTo(9.92375, 31);
    fullPath.lineTo(9.92375, 9.08);
    fullPath.lineTo(13.5638, 9.08);
    fullPath.close();
    fullPath.moveTo(30.4475, 8.68);
    fullPath.cubicTo(33.1142, 8.68, 35.2742, 9.49333, 36.9275, 11.12);
    fullPath.cubicTo(38.5808, 12.72, 39.4075, 15.04, 39.4075, 18.08);
    fullPath.lineTo(39.4075, 31);
    fullPath.lineTo(35.8075, 31);
    fullPath.lineTo(35.8075, 18.6);
    fullPath.cubicTo(35.8075, 16.4133, 35.2608, 14.7467, 34.1675, 13.6);
    fullPath.cubicTo(33.0742, 12.4267, 31.5808, 11.84, 29.6875, 11.84);
    fullPath.cubicTo(27.7675, 11.84, 26.2342, 12.44, 25.0875, 13.64);
    fullPath.cubicTo(23.9675, 14.84, 23.4075, 16.5867, 23.4075, 18.88);
    fullPath.lineTo(23.4075, 31);
    fullPath.lineTo(19.7675, 31);
    fullPath.lineTo(19.7675, 9.08);
    fullPath.lineTo(23.4075, 9.08);
    fullPath.lineTo(23.4075, 12.2);
    fullPath.cubicTo(24.1275, 11.08, 25.1008, 10.2133, 26.3275, 9.6);
    fullPath.cubicTo(27.5808, 8.98667, 28.9542, 8.68, 30.4475, 8.68);
    fullPath.close();
    fullPath.moveTo(57.5934, 31);
    fullPath.lineTo(48.9934, 21.32);
    fullPath.lineTo(48.9934, 31);
    fullPath.lineTo(45.3534, 31);
    fullPath.lineTo(45.3534, 1.4);
    fullPath.lineTo(48.9934, 1.4);
    fullPath.lineTo(48.9934, 18.8);
    fullPath.lineTo(57.4334, 9.08);
    fullPath.lineTo(62.5134, 9.08);
    fullPath.lineTo(52.1934, 20);
    fullPath.lineTo(62.5534, 31);
    fullPath.lineTo(57.5934, 31);
    fullPath.close();
    fullPath.moveTo(85.3794, 9.08);
    fullPath.lineTo(85.3794, 31);
    fullPath.lineTo(81.7394, 31);
    fullPath.lineTo(81.7394, 27.76);
    fullPath.cubicTo(81.046, 28.88, 80.0727, 29.76, 78.8194, 30.4);
    fullPath.cubicTo(77.5927, 31.0133, 76.2327, 31.32, 74.7394, 31.32);
    fullPath.cubicTo(73.0327, 31.32, 71.4994, 30.9733, 70.1394, 30.28);
    fullPath.cubicTo(68.7794, 29.56, 67.6994, 28.4933, 66.8994, 27.08);
    fullPath.cubicTo(66.126, 25.6667, 65.7394, 23.9467, 65.7394, 21.92);
    fullPath.lineTo(65.7394, 9.08);
    fullPath.lineTo(69.3394, 9.08);
    fullPath.lineTo(69.3394, 21.44);
    fullPath.cubicTo(69.3394, 23.6, 69.886, 25.2667, 70.9794, 26.44);
    fullPath.cubicTo(72.0727, 27.5867, 73.566, 28.16, 75.4594, 28.16);
    fullPath.cubicTo(77.406, 28.16, 78.9394, 27.56, 80.0594, 26.36);
    fullPath.cubicTo(81.1794, 25.16, 81.7394, 23.4133, 81.7394, 21.12);
    fullPath.lineTo(81.7394, 9.08);
    fullPath.lineTo(85.3794, 9.08);
    fullPath.close();
    fullPath.moveTo(95.1653, 13.12);
    fullPath.cubicTo(95.8853, 11.8667, 96.952, 10.8267, 98.3653, 10);
    fullPath.cubicTo(99.8053, 9.14667, 101.472, 8.72, 103.365, 8.72);
    fullPath.cubicTo(105.312, 8.72, 107.072, 9.18667, 108.645, 10.12);
    fullPath.cubicTo(110.245, 11.0533, 111.499, 12.3733, 112.405, 14.08);
    fullPath.cubicTo(113.312, 15.76, 113.765, 17.72, 113.765, 19.96);
    fullPath.cubicTo(113.765, 22.1733, 113.312, 24.1467, 112.405, 25.88);
    fullPath.cubicTo(111.499, 27.6133, 110.245, 28.96, 108.645, 29.92);
    fullPath.cubicTo(107.072, 30.88, 105.312, 31.36, 103.365, 31.36);
    fullPath.cubicTo(101.499, 31.36, 99.8453, 30.9467, 98.4053, 30.12);
    fullPath.cubicTo(96.992, 29.2667, 95.912, 28.2133, 95.1653, 26.96);
    fullPath.lineTo(95.1653, 41.4);
    fullPath.lineTo(91.5253, 41.4);
    fullPath.lineTo(91.5253, 9.08);
    fullPath.lineTo(95.1653, 9.08);
    fullPath.lineTo(95.1653, 13.12);
    fullPath.close();
    fullPath.moveTo(110.045, 19.96);
    fullPath.cubicTo(110.045, 18.3067, 109.712, 16.8667, 109.045, 15.64);
    fullPath.cubicTo(108.379, 14.4133, 107.472, 13.48, 106.325, 12.84);
    fullPath.cubicTo(105.205, 12.2, 103.965, 11.88, 102.605, 11.88);
    fullPath.cubicTo(101.272, 11.88, 100.032, 12.2133, 98.8853, 12.88);
    fullPath.cubicTo(97.7653, 13.52, 96.8586, 14.4667, 96.1653, 15.72);
    fullPath.cubicTo(95.4986, 16.9467, 95.1653, 18.3733, 95.1653, 20);
    fullPath.cubicTo(95.1653, 21.6533, 95.4986, 23.1067, 96.1653, 24.36);
    fullPath.cubicTo(96.8586, 25.5867, 97.7653, 26.5333, 98.8853, 27.2);
    fullPath.cubicTo(100.032, 27.84, 101.272, 28.16, 102.605, 28.16);
    fullPath.cubicTo(103.965, 28.16, 105.205, 27.84, 106.325, 27.2);
    fullPath.cubicTo(107.472, 26.5333, 108.379, 25.5867, 109.045, 24.36);
    fullPath.cubicTo(109.712, 23.1067, 110.045, 21.64, 110.045, 19.96);
    fullPath.close();

    ui.PathMetrics pms = fullPath.computeMetrics(forceClosed: false);
    Path animatedPath = Path();

    for (var pm in pms) {
      final len = pm.length * progress.value;
      animatedPath.addPath(pm.extractPath(0, len), Offset.zero);
    }

    var strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = Colors.transparent;

    if (progress.value > 0.01) {
      strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = color;
    }

    canvas.drawPath(animatedPath, strokePaint);

    if (progress.value > 0.3) {
      double adjustedOpacity = ((progress.value - 0.3) / 0.7).clamp(0.0, 1.0);
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: adjustedOpacity);
      canvas.drawPath(fullPath, fillPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
