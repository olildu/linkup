import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/data/models/message_group_model.dart';
import 'package:linkup/features/messaging/presentation/components/calculate_border_shape.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  MessageGroupModel group({
    bool first = false,
    bool last = false,
    bool only = false,
    bool prevEmoji = false,
    bool nextEmoji = false,
  }) =>
      MessageGroupModel(
        isFirstInGroup: first,
        isLastInGroup: last,
        isOnlyMessageInGroup: only,
        groupSize: 3,
        positionInGroup: 1,
        prevMessageEmoji: prevEmoji,
        nextMessageEmoji: nextEmoji,
      );

  Future<BorderRadius> compute(
    WidgetTester tester, {
    required MessageGroupModel groupInfo,
    bool isSentByMe = true,
    bool isOnlyEmoji = false,
    bool containsReply = false,
  }) async {
    late BorderRadius radius;
    await tester.pumpWidget(buildTestWidget(Builder(builder: (context) {
      radius = getBorderRadius(
        groupInfo: groupInfo,
        isSentByMe: isSentByMe,
        isOnlyEmoji: isOnlyEmoji,
        containsReply: containsReply,
      );
      return const SizedBox();
    })));
    return radius;
  }

  bool isUniform(BorderRadius r) =>
      r.topLeft == r.topRight &&
      r.topRight == r.bottomLeft &&
      r.bottomLeft == r.bottomRight;

  testWidgets('emoji, reply and single messages use a uniform large radius',
      (tester) async {
    expect(
        isUniform(await compute(tester,
            groupInfo: group(), isOnlyEmoji: true)),
        isTrue);
    expect(
        isUniform(await compute(tester,
            groupInfo: group(), containsReply: true)),
        isTrue);
    expect(isUniform(await compute(tester, groupInfo: group(only: true))),
        isTrue);
  });

  testWidgets('emoji neighbours force a full radius', (tester) async {
    expect(
        isUniform(await compute(tester,
            groupInfo: group(prevEmoji: true, nextEmoji: true))),
        isTrue);
    expect(
        isUniform(await compute(tester,
            groupInfo: group(prevEmoji: true, last: true))),
        isTrue);
    expect(
        isUniform(await compute(tester,
            groupInfo: group(nextEmoji: true, first: true))),
        isTrue);
  });

  testWidgets('sent messages pinch the right side within a group',
      (tester) async {
    final first = await compute(tester, groupInfo: group(first: true));
    expect(first.bottomRight.x, lessThan(first.topRight.x));

    final last = await compute(tester, groupInfo: group(last: true));
    expect(last.topRight.x, lessThan(last.bottomRight.x));

    final middle = await compute(tester, groupInfo: group());
    expect(middle.topRight, middle.bottomRight);
    expect(middle.topRight.x, lessThan(middle.topLeft.x));
  });

  testWidgets('received messages pinch the left side within a group',
      (tester) async {
    final first =
        await compute(tester, groupInfo: group(first: true), isSentByMe: false);
    expect(first.bottomLeft.x, lessThan(first.topLeft.x));

    final last =
        await compute(tester, groupInfo: group(last: true), isSentByMe: false);
    expect(last.topLeft.x, lessThan(last.bottomLeft.x));

    final middle =
        await compute(tester, groupInfo: group(), isSentByMe: false);
    expect(middle.topLeft, middle.bottomLeft);
    expect(middle.topLeft.x, lessThan(middle.topRight.x));
  });
}
