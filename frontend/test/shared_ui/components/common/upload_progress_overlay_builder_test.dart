import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/shared_ui/components/common/upload_progress_overlay_builder.dart';

import '../../../helpers/test_helper.dart';

void main() {
  testWidgets('shows the message with counts and an animated bar',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(const UploadProgressOverlayBuilder(
        current: 2, total: 4, message: 'Uploading photos...')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Uploading photos... 2/4'), findsOneWidget);
    final bar = tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(bar.value, closeTo(0.5, 0.01));
  });

  testWidgets('total of zero renders an empty bar without dividing by zero',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(const UploadProgressOverlayBuilder(
        current: 0, total: 0, message: 'Saving changes...')));
    await tester.pump(const Duration(milliseconds: 400));
    final bar = tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(bar.value, 0);
  });
}
