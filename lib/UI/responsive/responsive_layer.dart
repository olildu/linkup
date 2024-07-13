import 'package:flutter/material.dart';

class ResponsiveLayer extends StatelessWidget {
  final Widget mobileScaffold;
  final Widget desktopScaffold;
  final Widget createProfilePage;
  final bool createProfile;

  const ResponsiveLayer({
    super.key,
    required this.mobileScaffold,
    required this.desktopScaffold,
    required this.createProfilePage,
    this.createProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (createProfile){
          return createProfilePage;
        }
        if (constraints.maxWidth < 1000) {
          return mobileScaffold;
        } else {
          return desktopScaffold;
        }
      },
    );
  }
}
