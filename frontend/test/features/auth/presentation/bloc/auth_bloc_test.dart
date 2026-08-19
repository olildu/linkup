import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/errors/api_exception.dart';
import 'package:linkup/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockLoginUseCase login;
  late MockLogoutUseCase logout;
  late MockRegisterUseCase register;
  late MockResetPasswordUseCase resetPassword;
  late MockDeleteAccountUseCase deleteAccount;

  setUp(() {
    login = MockLoginUseCase();
    logout = MockLogoutUseCase();
    register = MockRegisterUseCase();
    resetPassword = MockResetPasswordUseCase();
    deleteAccount = MockDeleteAccountUseCase();
  });

  AuthBloc build() => AuthBloc(
        loginUseCase: login,
        logoutUseCase: logout,
        registerUseCase: register,
        resetPasswordUseCase: resetPassword,
        deleteAccountUseCase: deleteAccount,
      );

  Future<List<AuthState>> run(AuthEvent event,
      {required AuthBloc bloc}) async {
    final states = <AuthState>[];
    bloc.stream.listen(states.add);
    bloc.add(event);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return states;
  }

  test('login success emits Loading then Authenticated', () async {
    when(() => login('a@b.com', 'pw')).thenAnswer((_) async {});
    final bloc = build();
    final states = await run(
        AuthLoginRequested(email: 'a@b.com', password: 'pw'),
        bloc: bloc);
    expect(states, [isA<AuthLoading>(), isA<AuthAuthenticated>()]);
    await bloc.close();
  });

  test('login with unknown account emits AuthAccountNotFound', () async {
    when(() => login('a@b.com', 'pw'))
        .thenThrow(AccountNotFoundException('No account found.'));
    final bloc = build();
    final states = await run(
        AuthLoginRequested(email: 'a@b.com', password: 'pw'),
        bloc: bloc);
    expect(states.last, isA<AuthAccountNotFound>());
    expect((states.last as AuthAccountNotFound).message, 'No account found.');
    await bloc.close();
  });

  test('login failure emits a friendly AuthFailure', () async {
    when(() => login('a@b.com', 'pw')).thenThrow(ApiException(
        statusCode: 401, message: 'Wrong password.', rawDetail: 'bad'));
    final bloc = build();
    final states = await run(
        AuthLoginRequested(email: 'a@b.com', password: 'pw'),
        bloc: bloc);
    expect((states.last as AuthFailure).message, 'Wrong password.');
    await bloc.close();
  });

  test('register success and failure', () async {
    when(() => register('h', 'pw')).thenAnswer((_) async {});
    final bloc = build();
    var states = await run(
        AuthRegisterRequested(emailHash: 'h', password: 'pw'),
        bloc: bloc);
    expect(states.last, isA<AuthAuthenticated>());

    when(() => register('h', 'pw')).thenThrow(Exception('dup'));
    states = await run(AuthRegisterRequested(emailHash: 'h', password: 'pw'),
        bloc: bloc);
    expect(states.last, isA<AuthFailure>());
    await bloc.close();
  });

  test('reset password success and failure', () async {
    when(() => resetPassword('h', 'pw')).thenAnswer((_) async {});
    final bloc = build();
    var states = await run(
        AuthResetPasswordRequested(emailHash: 'h', password: 'pw'),
        bloc: bloc);
    expect(states.last, isA<AuthAuthenticated>());

    when(() => resetPassword('h', 'pw')).thenThrow(Exception('bad'));
    states = await run(
        AuthResetPasswordRequested(emailHash: 'h', password: 'pw'),
        bloc: bloc);
    expect(states.last, isA<AuthFailure>());
    await bloc.close();
  });

  test('logout and deleteAccount delegate to their use cases', () async {
    when(() => logout()).thenAnswer((_) async {});
    when(() => deleteAccount()).thenAnswer((_) async {});
    final bloc = build();
    await bloc.logout();
    await bloc.deleteAccount();
    verify(() => logout()).called(1);
    verify(() => deleteAccount()).called(1);
    await bloc.close();
  });
}
