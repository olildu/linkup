// Fixed: Used descendant finders to avoid 'Too many elements' error from AnimatedSwitcher.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/chat_page/event_intro_animation.dart';
import '../../../test_helper.dart';

void main() {
  group('EventIntroAnimation', () {
    testWidgets('starts animation and applies Slide/Fade transitions', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EventIntroAnimation(child: Text('Event')),
      ));

      // Use descendant finder to target the transitions applied to the child Text widget
      final textFinder = find.text('Event');
      final fadeTransitionFinder = find.ancestor(of: textFinder, matching: find.byType(FadeTransition)).first;
      final slideTransitionFinder = find.ancestor(of: fadeTransitionFinder, matching: find.byType(SlideTransition)).first;

      final slideTransition = tester.widget<SlideTransition>(slideTransitionFinder);
      final fadeTransition = tester.widget<FadeTransition>(fadeTransitionFinder);

      // Initial state (t=0)
      expect(fadeTransition.opacity.value, closeTo(0.0, 0.01));
      expect(slideTransition.position.value.dy, closeTo(1.0, 0.01));

      // Advance animation to completion (400ms duration)
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle(); // Ensure animation completes

      // Final state: Opacity should be 1, Offset should be 0
      expect(fadeTransition.opacity.value, closeTo(1.0, 0.01));
      expect(slideTransition.position.value.dy, closeTo(0.0, 0.01));
    });
  });
}