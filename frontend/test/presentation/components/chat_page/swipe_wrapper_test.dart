import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/data/models/chat_models/message_model.dart';
import 'package:linkup/presentation/components/chat_page/swipe_wrapper.dart';
import 'package:get_it/get_it.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../test_helper.dart';

void main() {
  setUpAll(() {
    GetIt.instance.registerSingleton<int>(123, instanceName: 'user_id');
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('shows reply icon when drag starts but does not trigger callback on short drag', (tester) async {
    bool swiped = false;
    final message = Message(
      id: '1', message: 'test', to: 456, from_: 123, 
      timestamp: DateTime.now(), chatRoomId: 1
    );

    await tester.pumpWidget(buildTestWidget(
      SwipeWrapper(
        payload: message,
        onSwipe: () => swiped = true,
        child: Container(key: const Key('message'), height: 50, width: 200, color: Colors.red),
      ),
    ));

    // Drag left a small amount (less than _triggerThreshold = 80)
    final gesture = await tester.startGesture(tester.getCenter(find.byKey(const Key('message'))));
    await gesture.moveBy(const Offset(-40, 0)); // Short drag
    await tester.pump();

    // The reply icon should be visible (Opacity > 0)
    expect(find.byIcon(Symbols.reply), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();

    // The message returns to position, and callback is NOT triggered
    expect(swiped, isFalse);
    final transformWidget = tester.widget<Transform>(find.byType(Transform).at(0));
    expect(transformWidget.transform.getTranslation().x, closeTo(0, 0.01));
  });
}