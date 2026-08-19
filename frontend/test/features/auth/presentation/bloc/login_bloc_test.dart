import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/auth/presentation/bloc/login_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  test('successful login emits Loading then Success', () async {
    final login = MockLoginUseCase();
    when(() => login('a@b.com', 'pw')).thenAnswer((_) async {});
    final bloc = LoginBloc(loginUseCase: login);
    final states = <LoginState>[];
    bloc.stream.listen(states.add);

    bloc.add(LoginSubmitted(email: 'a@b.com', password: 'pw'));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(states, [isA<LoginLoading>(), isA<LoginSuccess>()]);
    await bloc.close();
  });

  test('failed login emits LoginFailure with a friendly message', () async {
    final login = MockLoginUseCase();
    when(() => login('a@b.com', 'pw')).thenThrow(Exception('nope'));
    final bloc = LoginBloc(loginUseCase: login);
    final states = <LoginState>[];
    bloc.stream.listen(states.add);

    bloc.add(LoginSubmitted(email: 'a@b.com', password: 'pw'));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(states.last, isA<LoginFailure>());
    await bloc.close();
  });
}
