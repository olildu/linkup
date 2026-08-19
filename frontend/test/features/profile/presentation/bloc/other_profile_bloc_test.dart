import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/profile/presentation/bloc/other_profile_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  test('load emits Loading then Loaded, and Error on failure', () async {
    final getOther = MockGetOtherProfileUseCase();
    when(() => getOther(7)).thenAnswer((_) async => makeCandidate());
    final bloc = OtherProfileBloc(getOtherProfileUseCase: getOther);
    final states = <OtherProfileState>[];
    bloc.stream.listen(states.add);

    bloc.add(LoadOtherProfileEvent(7));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(states, [isA<OtherProfileLoading>(), isA<OtherProfileLoaded>()]);
    expect((states.last as OtherProfileLoaded).user.username, 'alice');

    when(() => getOther(7)).thenThrow(Exception('gone'));
    bloc.add(LoadOtherProfileEvent(7));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state, isA<OtherProfileError>());
    await bloc.close();
  });
}
