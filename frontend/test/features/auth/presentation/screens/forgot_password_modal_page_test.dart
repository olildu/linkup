import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:linkup/features/auth/presentation/bloc/otp_bloc.dart';
import 'package:linkup/features/auth/presentation/components/otp_input_field.dart';
import 'package:linkup/features/auth/presentation/screens/forgot_password_modal_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_blocs.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  setUpAll(registerBlocEventFallbacks);

  late MockAuthBloc authBloc;
  late MockOtpBloc otpBloc;
  final tabChanges = <String>[];

  setUp(() {
    authBloc = MockAuthBloc();
    otpBloc = MockOtpBloc();
    stubBloc<AuthState>(authBloc, AuthInitial());
    stubBloc<OtpState>(otpBloc, OtpInitial());
    when(() => authBloc.add(any())).thenReturn(null);
    when(() => otpBloc.add(any())).thenReturn(null);
    tabChanges.clear();
  });

  Future<void> pumpModal(WidgetTester tester,
      {String filledEmail = 'me@x.com'}) async {
    await tester.pumpWidget(buildTestWidgetWithBlocs(
      ForgotPasswordModalPage(
        tabHeightChange: tabChanges.add,
        filledEmail: filledEmail,
      ),
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<OtpBloc>.value(value: otpBloc),
      ],
    ));
  }

  testWidgets('prefills the email and sends the reset OTP', (tester) async {
    await pumpModal(tester);
    expect(find.text('me@x.com'), findsOneWidget);

    await tester.tap(find.text('Send OTP'));
    final sent = verify(() => otpBloc.add(captureAny()))
        .captured
        .whereType<SendOTPEvent>();
    expect(sent.single.email, 'me@x.com');
  });

  testWidgets('OtpSent switches to OTP entry and verifies with the '
      'forgot-password subject', (tester) async {
    final controller = stubBloc<OtpState>(otpBloc, OtpInitial());
    await pumpModal(tester);

    controller.add(OtpSent());
    await tester.pumpAndSettle();
    expect(tabChanges, contains('otp-entry'));
    expect(find.byType(OtpInputField), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, '654321');
    await tester.pump();
    await tester.tap(find.text('Verify OTP'));
    final events = verify(() => otpBloc.add(captureAny()))
        .captured
        .whereType<VerifyOTPEvent>();
    expect(events.single.otp, 654321);
  });

  testWidgets('OtpVerified shows the password step and resets the password',
      (tester) async {
    final controller = stubBloc<OtpState>(otpBloc, OtpInitial());
    await pumpModal(tester);

    controller.add(OtpVerified(emailHash: 'hash-9'));
    await tester.pumpAndSettle();
    expect(tabChanges, contains('password-entry'));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Abcdef1!');
    await tester.enterText(fields.at(1), 'Abcdef1!');
    await tester.pump();

    await tester.tap(find.text('Change Password'));
    final resets = verify(() => authBloc.add(captureAny()))
        .captured
        .whereType<AuthResetPasswordRequested>();
    expect(resets.single.emailHash, 'hash-9');
  });

  testWidgets('back arrow pops the modal', (tester) async {
    await tester.pumpWidget(buildTestWidget(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<OtpBloc>.value(value: otpBloc),
            ],
            child: ForgotPasswordModalPage(
                tabHeightChange: tabChanges.add, filledEmail: ''),
          ),
        ),
        child: const Text('open'),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordModalPage), findsNothing);
  });
}
