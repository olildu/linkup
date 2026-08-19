import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/auth/domain/use_cases/send_otp_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late SendOTPUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SendOTPUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.sendEmailOTP('a@b.com')).thenAnswer((_) async => 123456);

    expect(await useCase('a@b.com'), 123456);

    verify(() => repository.sendEmailOTP('a@b.com')).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.sendEmailOTP('a@b.com')).thenThrow(Exception('boom'));

    expect(() => useCase('a@b.com'), throwsException);
  });
}
