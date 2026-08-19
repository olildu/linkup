import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/entities/update_metadata_model.dart';
import 'package:linkup/features/profile/domain/update_profile_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockUserRepository repository;
  late UpdateProfileUseCase useCase;

  final data = UpdateMetadataModel(about: 'new about');
  setUp(() {
    repository = MockUserRepository();
    useCase = UpdateProfileUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.updateProfile(data, updatePfp: true)).thenAnswer((_) async {});

    await useCase(data, updatePfp: true);

    verify(() => repository.updateProfile(data, updatePfp: true)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.updateProfile(data, updatePfp: false)).thenThrow(Exception('boom'));

    expect(() => useCase(data), throwsException);
  });
}
