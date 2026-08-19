import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/profile/presentation/bloc/preferences_bloc.dart';
import 'package:linkup/features/profile/presentation/screens/set_preferences_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mock_blocs.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  setUpAll(registerBlocEventFallbacks);

  late MockPreferencesBloc preferencesBloc;

  setUp(() {
    preferencesBloc = MockPreferencesBloc();
    when(() => preferencesBloc.add(any())).thenReturn(null);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    usePhoneSurface(tester);
    ignoreOverflowErrors();
    await tester.pumpWidget(buildTestWidgetWithBlocs(
      const SetPreferencesPage(),
      providers: [
        BlocProvider<PreferencesBloc>.value(value: preferencesBloc),
      ],
    ));
    await tester.pump();
  }

  testWidgets('loads preferences on open and shows a spinner while loading',
      (tester) async {
    stubBloc<PreferencesState>(preferencesBloc, PreferencesLoading());
    await pumpPage(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final events = verify(() => preferencesBloc.add(captureAny())).captured;
    expect(events.whereType<PreferencesLoadEvent>(), hasLength(1));
  });

  testWidgets('loaded preferences render the option sections', (tester) async {
    stubBloc<PreferencesState>(preferencesBloc,
        PreferencesLoaded(userPreference: makePreference()));
    await pumpPage(tester);

    expect(find.text('Set Your Preferences'), findsOneWidget);
    expect(find.text('Interested Gender'), findsOneWidget);
    expect(find.text('Male'), findsWidgets);
    expect(find.text('Female'), findsWidgets);
  });

  testWidgets('choosing an option dispatches a preferences update',
      (tester) async {
    stubBloc<PreferencesState>(preferencesBloc,
        PreferencesLoaded(userPreference: makePreference()));
    await pumpPage(tester);

    await tester.tap(find.text('Male').first);
    await tester.pump();

    final events = verify(() => preferencesBloc.add(captureAny())).captured;
    final update = events.whereType<PreferencesUpdateEvent>().single;
    expect(update.userPreference.interestedGender, 'Male');
  });
}
