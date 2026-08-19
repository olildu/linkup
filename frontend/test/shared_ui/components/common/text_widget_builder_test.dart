import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/shared_ui/components/common/text_widget_builder.dart';

import '../../../helpers/test_helper.dart';

void main() {
  testWidgets('renders the text with defaults from the theme', (tester) async {
    await tester.pumpWidget(buildTestWidget(const CustomTextWidget('hello')));
    final text = tester.widget<Text>(find.text('hello'));
    expect(text.style!.fontWeight, FontWeight.w400);
    expect(text.textAlign, TextAlign.left);
  });

  testWidgets('honours explicit color, maxLines and overflow', (tester) async {
    await tester.pumpWidget(buildTestWidget(const CustomTextWidget(
      'clipped',
      color: Colors.red,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      fontWeight: FontWeight.w700,
    )));
    final text = tester.widget<Text>(find.text('clipped'));
    expect(text.style!.color, Colors.red);
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(text.style!.fontWeight, FontWeight.w700);
  });
}
