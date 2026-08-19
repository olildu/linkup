import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/enums/otp_subject_enum.dart';
import 'package:linkup/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late VerifyOTPUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = VerifyOTPUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.verifyEmailOTP('a@b.com', 111111, EmailOTPSubject.emailVerification)).thenAnswer((_) async => {'ok': true});

    expect(await useCase('a@b.com', 111111, EmailOTPSubject.emailVerification), {'ok': true});

    verify(() => repository.verifyEmailOTP('a@b.com', 111111, EmailOTPSubject.emailVerification)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.verifyEmailOTP('a@b.com', 111111, EmailOTPSubject.forgotPassword)).thenThrow(Exception('boom'));

    expect(() => useCase('a@b.com', 111111, EmailOTPSubject.forgotPassword), throwsException);
  });
}
