import 'package:flutter/material.dart';

class ResponsiveLayer extends StatelessWidget {
  final Widget mobileScaffold;
  final Widget desktopScaffold;

  const ResponsiveLayer({
    super.key,
    required this.mobileScaffold,
    required this.desktopScaffold,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          return mobileScaffold;
        } else {
          return desktopScaffold;
        }
      },
    );
  }
}
