import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/shared_ui/constants/colors.dart'; //

/// Sizes the test surface like a phone (411x866 logical, the app's design
/// size) so full screens lay out without overflowing the default 800x600
/// test window. Resets automatically after the test.
void usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(411.43 * 2, 866.28 * 2);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
}

/// Suppresses RenderFlex overflow exceptions for the current test. Use for
/// screens that slightly overflow the test surface; every other exception
/// still fails the test. Restored automatically on teardown.
void ignoreOverflowErrors() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    final exception = details.exception;
    final isOverflow = exception is FlutterError &&
        exception.message.contains('overflowed by');
    if (!isOverflow) original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);
}

/// Suppresses "Looking up a deactivated widget's ancestor" errors thrown by
/// VisibilityDetector callbacks that fire while the test tree is being torn
/// down. Real mid-test exceptions still fail the test.
void ignoreDeactivatedAncestorErrors() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    final text = details.exception.toString();
    if (text.contains("deactivated widget's ancestor")) return;
    original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);
}

// This helper is mandatory for testing widgets that use:
// 1. Theme.of(context) (MaterialApp/ThemeData)
// 2. .sp/.h/.w extensions (ScreenUtilInit)
// 3. Navigation/Scaffold context (Scaffold)
Widget buildTestWidget(Widget child, {NavigatorObserver? navigatorObserver}) {
  // Uses the design size (411.43, 866.28) defined in lib/main.dart
  return ScreenUtilInit(
    designSize: const Size(411.43, 866.28),
    builder: (context, _) => MaterialApp(
      // Provides both light and dark themes for theme-dependent widgets
      theme: AppTheme.lightTheme, //
      darkTheme: AppTheme.darkTheme, //
      navigatorObservers: [if (navigatorObserver != null) navigatorObserver],
      // Wraps the component in a Scaffold body for context access
      home: Scaffold(body: child),
    ),
  );
}

// Same shell as buildTestWidget but with blocs/cubits provided above the
// child, so widgets using context.read/watch/BlocBuilder can find them.
// Pass mocked blocs via BlocProvider<X>.value(value: mockX).
Widget buildTestWidgetWithBlocs(
  Widget child, {
  required List<BlocProvider> providers,
  NavigatorObserver? navigatorObserver,
}) {
  // Providers wrap the MaterialApp so blocs stay reachable from pushed
  // routes and modals, matching main.dart's MultiBlocProvider placement.
  return MultiBlocProvider(
    providers: providers,
    child: buildTestWidget(child, navigatorObserver: navigatorObserver),
  );
}
