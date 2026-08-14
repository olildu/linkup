import 'package:flutter/cupertino.dart';

void navigateWithFade(
  BuildContext context,
  Widget page, {
  bool allowBack = true,
}) {
  final route = PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 500),
  );

  if (allowBack) {
    Navigator.of(context).push(route); // keeps previous routes alive
  } else {
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }
}
