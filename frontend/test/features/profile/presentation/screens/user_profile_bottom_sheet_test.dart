import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:linkup/features/profile/presentation/bloc/other_profile_bloc.dart';
import 'package:linkup/features/profile/presentation/screens/user_profile_bottom_sheet.dart';
import 'package:linkup/shared_ui/components/candidate_detail_scroll/candidate_detail_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  late MockGetOtherProfileUseCase getOtherProfile;

  setUp(() async {
    getOtherProfile = MockGetOtherProfileUseCase();
    final sl = GetIt.instance;
    await sl.reset();
    sl.registerFactory<OtherProfileBloc>(
        () => OtherProfileBloc(getOtherProfileUseCase: getOtherProfile));
  });

  Future<void> openSheet(WidgetTester tester,
      {bool showChatButton = true}) async {
    usePhoneSurface(tester);
    ignoreOverflowErrors();
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildTestWidget(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showBottomSheetUserProfile(
              context: context, userId: 7, showChatButton: showChatButton),
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    });
  }

  testWidgets('loads the profile and shows the candidate details',
      (tester) async {
    when(() => getOtherProfile(7)).thenAnswer((_) async => makeCandidate());
    await openSheet(tester);
    await mockNetworkImagesFor(() => tester.pump());

    expect(find.byType(CandidateDetailBuilder), findsOneWidget);
  });

  testWidgets('shows the error message when loading fails', (tester) async {
    when(() => getOtherProfile(7)).thenThrow(Exception('gone'));
    await openSheet(tester);
    await tester.pump();

    expect(find.text('Error loading profile'), findsOneWidget);
  });
}
