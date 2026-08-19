import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:linkup/features/auth/presentation/bloc/otp_bloc.dart';
import 'package:linkup/features/auth/presentation/components/otp_input_field.dart';
import 'package:linkup/features/onboarding/presentation/screens/signup_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_blocs.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  setUpAll(registerBlocEventFallbacks);

  late MockAuthBloc authBloc;
  late MockOtpBloc otpBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    otpBloc = MockOtpBloc();
    stubBloc<AuthState>(authBloc, AuthInitial());
    stubBloc<OtpState>(otpBloc, OtpInitial());
    when(() => authBloc.add(any())).thenReturn(null);
    when(() => otpBloc.add(any())).thenReturn(null);
  });

  final tabChanges = <int>[];

  Future<void> pumpSignup(WidgetTester tester) async {
    tabChanges.clear();
    await tester.pumpWidget(buildTestWidgetWithBlocs(
      SignUpPage(tabHeightChange: tabChanges.add),
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<OtpBloc>.value(value: otpBloc),
      ],
    ));
  }

  testWidgets('email step sends the OTP request', (tester) async {
    await pumpSignup(tester);
    expect(find.text('Verify with OTP'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'a@muj.edu.in');
    await tester.pump();
    await tester.tap(find.text('Verify with OTP'));

    final sent =
        verify(() => otpBloc.add(captureAny())).captured.whereType<SendOTPEvent>();
    expect(sent.single.email, 'a@muj.edu.in');
  });

  testWidgets('email failure shows the inline error', (tester) async {
    stubBloc<OtpState>(otpBloc, OtpFailure(message: 'Failed to send OTP'));
    await pumpSignup(tester);
    expect(find.text('Failed to send OTP'), findsOneWidget);
  });

  testWidgets('OtpSent state shows the OTP entry and submits it',
      (tester) async {
    stubBloc<OtpState>(otpBloc, OtpSent());
    await pumpSignup(tester);
    await tester.pumpAndSettle();

    expect(find.byType(OtpInputField), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '123456');
    await tester.pump();
    await tester.tap(find.text('Submit OTP'));

    final events =
        verify(() => otpBloc.add(captureAny())).captured.whereType<VerifyOTPEvent>();
    expect(events.single.otp, 123456);
  });

  testWidgets('OtpVerified moves to the password step and registers',
      (tester) async {
    final controller = stubBloc<OtpState>(otpBloc, OtpInitial());
    await pumpSignup(tester);

    controller.add(OtpVerified(emailHash: 'hash-1'));
    await tester.pumpAndSettle();

    expect(tabChanges, contains(2));
    expect(find.text('Save password'), findsOneWidget);
    expect(find.text('One uppercase letter'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Abcdef1!');
    await tester.enterText(fields.at(1), 'Abcdef1!');
    await tester.pump();

    await tester.tap(find.text('Save password'));
    final registered = verify(() => authBloc.add(captureAny()))
        .captured
        .whereType<AuthRegisterRequested>();
    expect(registered.single.emailHash, 'hash-1');
    expect(registered.single.password, 'Abcdef1!');
  });
}
