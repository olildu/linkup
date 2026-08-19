import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/likes/presentation/bloc/likes_bloc.dart';
import 'package:linkup/features/discovery/presentation/screens/matched_page.dart';
import 'package:linkup/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:linkup/features/likes/presentation/screens/likes_you_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mock_blocs.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  setUpAll(() {
    registerBlocEventFallbacks();
    registerFallbackValue(LoadReceivedLikesEvent());
  });

  late MockLikesBloc likesBloc;
  late MockProfileBloc profileBloc;

  setUp(() {
    likesBloc = MockLikesBloc();
    profileBloc = MockProfileBloc();
    when(() => likesBloc.add(any())).thenReturn(null);
    when(() => profileBloc.add(any())).thenReturn(null);
    stubBloc<ProfileState>(profileBloc, ProfileLoaded(user: makeUser()));
  });

  Future<void> pumpPage(WidgetTester tester) async {
    usePhoneSurface(tester);
    return mockNetworkImagesFor(
        () => tester.pumpWidget(buildTestWidgetWithBlocs(
          const LikesYouPage(),
          providers: [
            BlocProvider<LikesBloc>.value(value: likesBloc),
            BlocProvider<ProfileBloc>.value(value: profileBloc),
          ],
        )),
      );
  }

  testWidgets('requests a refresh on open and shows the shimmer while loading',
      (tester) async {
    stubBloc<LikesState>(likesBloc, LikesInitial());
    await pumpPage(tester);
    await tester.pump(const Duration(milliseconds: 100));

    final captured = verify(() => likesBloc.add(captureAny())).captured;
    expect(captured.whereType<LoadReceivedLikesEvent>().single.refresh, isTrue);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('error state shows the retry copy', (tester) async {
    stubBloc<LikesState>(likesBloc, LikesError());
    await pumpPage(tester);
    await tester.pump();
    expect(find.text('Something went wrong'), findsOneWidget);
  });

  testWidgets('empty loaded state shows "No likes yet"', (tester) async {
    stubBloc<LikesState>(likesBloc,
        LikesLoaded(entries: const [], totalCount: 0, unseenCount: 0));
    await pumpPage(tester);
    await tester.pump();
    expect(find.text('No likes yet'), findsOneWidget);
  });

  testWidgets('renders blurred cards for hidden likes and clear for revealed',
      (tester) async {
    stubBloc<LikesState>(
        likesBloc,
        LikesLoaded(
          entries: [
            makeLikesEntry(id: 1, revealed: false),
            makeLikesEntry(id: 2, revealed: true),
          ],
          totalCount: 2,
          unseenCount: 1,
        ));
    await pumpPage(tester);
    await tester.pump();

    // Hidden entry shows the heart overlay.
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.byType(GestureDetector), findsWidgets);
  });

  testWidgets('tapping a revealed like opens the profile sheet with actions',
      (tester) async {
    stubBloc<LikesState>(
        likesBloc,
        LikesLoaded(
          entries: [makeLikesEntry(id: 2, revealed: true)],
          totalCount: 1,
          unseenCount: 0,
        ));
    await pumpPage(tester);
    await tester.pump();

    await mockNetworkImagesFor(() async {
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    });

    expect(find.text('Like back'), findsOneWidget);
    expect(find.text('Pass'), findsOneWidget);

    await tester.tap(find.text('Like back'));
    await tester.pump(const Duration(milliseconds: 400));
    final events = verify(() => likesBloc.add(captureAny())).captured;
    expect(events.whereType<LikeBackEvent>().single.likerId, 2);
  });

  testWidgets('a match in state pushes MatchedPage', (tester) async {
    ignoreOverflowErrors();
    final controller = stubBloc<LikesState>(likesBloc,
        LikesLoaded(entries: const [], totalCount: 0, unseenCount: 0));
    await pumpPage(tester);
    await tester.pump();

    controller.add(LikesLoaded(
      entries: const [],
      totalCount: 0,
      unseenCount: 0,
      matchUser: makeMatchesConnection(),
    ));
    await mockNetworkImagesFor(() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    });

    // MatchedPage pushed on top of the likes page.
    expect(find.byType(MatchedPage), findsOneWidget);
  });
}
