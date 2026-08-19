import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/profile/presentation/bloc/preferences_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockGetPreferenceUseCase getPreference;
  late MockUpdatePreferenceUseCase updatePreference;

  setUp(() {
    getPreference = MockGetPreferenceUseCase();
    updatePreference = MockUpdatePreferenceUseCase();
  });

  PreferencesBloc build() => PreferencesBloc(
        getPreferenceUseCase: getPreference,
        updatePreferenceUseCase: updatePreference,
      );

  test('load emits Loading then Loaded, and Error on failure', () async {
    when(() => getPreference()).thenAnswer((_) async => makePreference());
    final bloc = build();
    final states = <PreferencesState>[];
    bloc.stream.listen(states.add);

    bloc.add(PreferencesLoadEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(states, [isA<PreferencesLoading>(), isA<PreferencesLoaded>()]);

    when(() => getPreference()).thenThrow(Exception('down'));
    bloc.add(PreferencesLoadEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state, isA<PreferencesError>());
    await bloc.close();
  });

  test('update optimistically emits the new preference and persists it',
      () async {
    final preference = makePreference();
    when(() => updatePreference(preference)).thenAnswer((_) async {});
    final bloc = build();

    bloc.add(PreferencesUpdateEvent(userPreference: preference));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect((bloc.state as PreferencesLoaded).userPreference, preference);
    verify(() => updatePreference(preference)).called(1);

    // A failing persist keeps the optimistic state.
    when(() => updatePreference(preference)).thenThrow(Exception('down'));
    bloc.add(PreferencesUpdateEvent(userPreference: preference));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state, isA<PreferencesLoaded>());
    await bloc.close();
  });
}
