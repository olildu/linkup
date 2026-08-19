import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:linkup/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:linkup/features/profile/presentation/screens/profile_settings_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mock_blocs.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  setUpAll(registerBlocEventFallbacks);

  late MockProfileBloc profileBloc;

  setUp(() async {
    profileBloc = MockProfileBloc();
    when(() => profileBloc.add(any())).thenReturn(null);
    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<int>(1, instanceName: 'user_id');
  });

  Future<void> pumpPage(WidgetTester tester) async {
    usePhoneSurface(tester);
    ignoreOverflowErrors();
    await mockNetworkImagesFor(() => tester.pumpWidget(buildTestWidgetWithBlocs(
          const ProfileSettingsPage(),
          providers: [BlocProvider<ProfileBloc>.value(value: profileBloc)],
        )));
    await tester.pump();
  }

  testWidgets('error state shows the failure message', (tester) async {
    stubBloc<ProfileState>(profileBloc, ProfileError());
    await pumpPage(tester);
    expect(find.byType(ProfileSettingsPage), findsOneWidget);
    expect(find.textContaining('Profile Settings'), findsOneWidget);
  });

  testWidgets('loaded profile renders the editing sections', (tester) async {
    stubBloc<ProfileState>(profileBloc, ProfileLoaded(user: makeUser()));
    await pumpPage(tester);

    expect(find.text('Profile Picture'), findsOneWidget);
    expect(find.text('About Me'), findsOneWidget);
    expect(find.text('Your Information'), findsOneWidget);
    expect(find.text('Preview Profile'), findsOneWidget);
  });

  testWidgets('uploading state shows the progress overlay', (tester) async {
    final controller =
        stubBloc<ProfileState>(profileBloc, ProfileLoaded(user: makeUser()));
    await pumpPage(tester);

    controller.add(
        ProfileUpdating(current: 1, total: 3, message: 'Uploading photos...'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    expect(find.text('Uploading photos... 1/3'), findsOneWidget);
  });
}
