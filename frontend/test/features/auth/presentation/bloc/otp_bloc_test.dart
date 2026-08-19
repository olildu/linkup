import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/enums/otp_subject_enum.dart';
import 'package:linkup/features/auth/presentation/bloc/otp_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockSendOTPUseCase sendOtp;
  late MockVerifyOTPUseCase verifyOtp;

  setUp(() {
    sendOtp = MockSendOTPUseCase();
    verifyOtp = MockVerifyOTPUseCase();
  });

  OtpBloc build() =>
      OtpBloc(sendOTPUseCase: sendOtp, verifyOTPUseCase: verifyOtp);

  Future<List<OtpState>> run(OtpBlocEvent event, OtpBloc bloc) async {
    final states = <OtpState>[];
    bloc.stream.listen(states.add);
    bloc.add(event);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return states;
  }

  test('send OTP emits OtpSent on 200, failure on other codes and throws',
      () async {
    final bloc = build();
    when(() => sendOtp('a@b.com')).thenAnswer((_) async => 200);
    var states = await run(SendOTPEvent(email: 'a@b.com'), bloc);
    expect(states, [isA<OtpLoading>(), isA<OtpSent>()]);

    when(() => sendOtp('a@b.com')).thenAnswer((_) async => 500);
    states = await run(SendOTPEvent(email: 'a@b.com'), bloc);
    expect(states.last, isA<OtpFailure>());

    when(() => sendOtp('a@b.com')).thenThrow(Exception('down'));
    states = await run(SendOTPEvent(email: 'a@b.com'), bloc);
    expect(states.last, isA<OtpFailure>());
    await bloc.close();
  });

  test('verify OTP emits OtpVerified with the email hash', () async {
    final bloc = build();
    when(() => verifyOtp('a@b.com', 111111, EmailOTPSubject.emailVerification))
        .thenAnswer((_) async => {'email_hash': 'h'});
    final states = await run(
        VerifyOTPEvent(
            otp: 111111,
            email: 'a@b.com',
            subject: EmailOTPSubject.emailVerification),
        bloc);
    expect((states.last as OtpVerified).emailHash, 'h');

    when(() => verifyOtp('a@b.com', 1, EmailOTPSubject.forgotPassword))
        .thenThrow(Exception('wrong'));
    final failStates = await run(
        VerifyOTPEvent(
            otp: 1,
            email: 'a@b.com',
            subject: EmailOTPSubject.forgotPassword),
        bloc);
    expect(failStates.last, isA<OtpFailure>());
    await bloc.close();
  });
}
