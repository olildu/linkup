import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/chat_page/sending_animation.dart';
import '../../../test_helper.dart';

void main() {
  testWidgets('SendingAnimation cycles opacity and continues animating', (tester) async {
    await tester.pumpWidget(buildTestWidget(const SendingAnimation()));

    final opacityFinder = find.byType(Opacity);
    double getOpacity() => tester.widget<Opacity>(opacityFinder).opacity;

    // 1. Initial state check: Opacity starts at 0.5
    expect(getOpacity(), closeTo(0.5, 0.01));

    // 2. Pump halfway (500ms).
    // The animation goes 0.5 -> 1.0. Halfway should be approx 0.75.
    await tester.pump(const Duration(milliseconds: 500));
    expect(getOpacity(), greaterThan(0.6));
    expect(getOpacity(), lessThan(0.9));

    // 3. Pump almost to the end (another 400ms -> 900ms total). 
    // Should be very close to 1.0 now.
    await tester.pump(const Duration(milliseconds: 400));
    expect(getOpacity(), closeTo(1.0, 0.1));

    // 4. Pump enough to complete the first cycle (100ms) and trigger rebuild
    await tester.pump(const Duration(milliseconds: 100)); // Total 1000ms. onEnd fires. Value is 1.0.
    
    // 5. Pump into the next cycle (reverse: 1.0 -> 0.5)
    // Advance 500ms into the new animation
    await tester.pump(const Duration(milliseconds: 500)); 
    
    // Now it should be midway back down (~0.75)
    expect(getOpacity(), lessThan(0.99)); // Distinctly less than 1.0
    expect(getOpacity(), greaterThan(0.51)); // Distinctly more than 0.5

    // Check that the animation is still scheduling frames (looping)
    expect(tester.binding.hasScheduledFrame, isTrue);
  });
}