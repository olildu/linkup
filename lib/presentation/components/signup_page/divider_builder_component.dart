import 'package:flutter/material.dart';

Widget buildDivider({
  required double height,
  required Color color,
  required BorderRadius borderRadius,
}) {
  return Container(
    height: height,
    decoration: BoxDecoration(color: color, borderRadius: borderRadius),
  );
}
