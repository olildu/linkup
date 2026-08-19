import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/entities/update_metadata_model.dart';
import 'package:linkup/features/auth/domain/use_cases/complete_profile_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late CompleteProfileUseCase useCase;

  final data = UpdateMetadataModel(username: 'u');
  setUp(() {
    repository = MockAuthRepository();
    useCase = CompleteProfileUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.completeProfile(data)).thenAnswer((_) async => true);

    expect(await useCase(data), isTrue);

    verify(() => repository.completeProfile(data)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.completeProfile(data)).thenThrow(Exception('boom'));

    expect(() => useCase(data), throwsException);
  });
}
