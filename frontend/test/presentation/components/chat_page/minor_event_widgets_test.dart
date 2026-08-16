import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/chat_page/minor_event_widgets.dart';
import 'package:linkup/presentation/components/chat_page/event_intro_animation.dart';
import '../../../test_helper.dart';

void main() {
  const mockImageMetaData = {
    'url': 'http://img.jpg', 
    'blurhash': r"|HF}[*IU1j-p$gNHVsofWXEMofxCNGt6s.WYazayEgjZ$%WVNGofa}f6kCIrof$$ayNHayoyayof-oR*Rjs:Nbj]xZWVaeNdofn~WBoLWBofoLWVxtayNHa}xZj[Rkj[WV%1fkIpoet6WBs.j[R*xaayRka#ofoLR*fkjs"
  };

  testWidgets('buildTypingIndicator renders profile image and text', (tester) async {
    // FIX: Use a Builder to get the context safely *during* the build, not before.
    await tester.pumpWidget(buildTestWidget(
      Builder(
        builder: (context) {
          return buildTypingIndicator(
            context: context, 
            imageMetaData: mockImageMetaData, 
            userName: 'Alice'
          );
        }
      ),
    ));
    
    // Pump frames to allow images/animations to settle
    await tester.pump(); 
    await tester.pumpAndSettle();

    expect(find.text('Alice is typing...'), findsOneWidget);
    expect(find.byType(ClipOval), findsOneWidget); 
    // Expect the animation wrapper
    expect(find.byType(EventIntroAnimation), findsOneWidget);
  });

  testWidgets('buildSeenIndicator renders "Seen" text', (tester) async {
    // FIX: Use Builder here too, because .sp (ScreenUtil) inside the widget 
    // requires the context to be fully initialized by ScreenUtilInit first.
    await tester.pumpWidget(buildTestWidget(
      Builder(
        builder: (context) {
          return buildSeenIndicator();
        }
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Seen'), findsOneWidget);
    expect(find.byType(EventIntroAnimation), findsOneWidget);
  });
}