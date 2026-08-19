import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/shared_ui/components/common/menu_tile_builder.dart';

import '../../../helpers/test_helper.dart';

void main() {
  testWidgets('renders title/subtitle, fires onTap and shows the arrow',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(buildTestWidget(MenuTileBuilder(
      icon: Icons.settings,
      title: 'Settings',
      subtitle: 'App preferences',
      onTap: () => tapped = true,
    )));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('App preferences'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);

    await tester.tap(find.text('Settings'));
    expect(tapped, isTrue);
  });

  testWidgets('renders trailingText variant', (tester) async {
    await tester.pumpWidget(buildTestWidget(MenuTileBuilder(
      icon: Icons.person,
      title: 'Account',
      trailingText: 'me@x.com',
      onTap: () {},
    )));
    expect(find.text('me@x.com'), findsOneWidget);
  });

  testWidgets('renders trailingWidget variant with subtitle', (tester) async {
    await tester.pumpWidget(buildTestWidget(MenuTileBuilder(
      icon: Icons.lock,
      title: 'App lock',
      subtitle: 'Biometric',
      trailingWidget: Switch(value: true, onChanged: (_) {}),
      onTap: () {},
    )));
    expect(find.byType(Switch), findsOneWidget);
    expect(find.text('Biometric'), findsOneWidget);
  });
}
