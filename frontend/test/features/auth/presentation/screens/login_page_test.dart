import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:linkup/features/auth/presentation/components/text_input_field.dart';
import 'package:linkup/features/auth/presentation/screens/login_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_blocs.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  setUpAll(registerBlocEventFallbacks);

  late MockAuthBloc authBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    stubBloc<AuthState>(authBloc, AuthInitial());
    when(() => authBloc.add(any())).thenReturn(null);
  });

  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidgetWithBlocs(
      const LoginPage(),
      providers: [BlocProvider<AuthBloc>.value(value: authBloc)],
    ));
  }

  testWidgets('renders email/password fields and forgot password link',
      (tester) async {
    await pumpLogin(tester);
    expect(find.byType(TextInputField), findsNWidgets(2));
    expect(find.text('Forgot Password ?'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('valid credentials enable the button and dispatch login',
      (tester) async {
    await pumpLogin(tester);

    await tester.enterText(
        find.byType(TextField).first, 'user@test.com');
    await tester.enterText(find.byType(TextField).last, 'longenough');
    await tester.pump();

    await tester.tap(find.text('Log In'));
    final captured =
        verify(() => authBloc.add(captureAny())).captured;
    final loginEvent =
        captured.whereType<AuthLoginRequested>().single;
    expect(loginEvent.email, 'user@test.com');
    expect(loginEvent.password, 'longenough');
  });

  testWidgets('password visibility toggle flips obscureText', (tester) async {
    await pumpLogin(tester);
    final before = tester
        .widget<TextField>(find.byType(TextField).last)
        .obscureText;
    await tester.tap(find.byType(IconButton).last);
    await tester.pump();
    final after = tester
        .widget<TextField>(find.byType(TextField).last)
        .obscureText;
    expect(after, !before);
  });

  testWidgets('AuthLoading disables the button and shows the spinner',
      (tester) async {
    stubBloc<AuthState>(authBloc, AuthLoading());
    await pumpLogin(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AuthFailure state shows a toast via the listener',
      (tester) async {
    final controller = stubBloc<AuthState>(authBloc, AuthInitial());
    await pumpLogin(tester);

    controller.add(AuthFailure(message: 'Wrong password.'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Wrong password.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('AuthAuthenticated pops the modal with true', (tester) async {
    final controller = stubBloc<AuthState>(authBloc, AuthInitial());
    late BuildContext pageContext;
    await tester.pumpWidget(buildTestWidget(Builder(builder: (context) {
      pageContext = context;
      return ElevatedButton(
        onPressed: () async {
          await showModalBottomSheet<bool>(
            context: context,
            builder: (_) => BlocProvider<AuthBloc>.value(
              value: authBloc,
              child: const LoginPage(),
            ),
          );
        },
        child: const Text('open'),
      );
    })));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    controller.add(AuthAuthenticated());
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsNothing);
    expect(pageContext.mounted, isTrue);
  });
}
