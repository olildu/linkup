import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/profile/domain/upload_pfp_from_url_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockMediaRepository repository;
  late UploadPfpFromUrlUseCase useCase;

  setUp(() {
    repository = MockMediaRepository();
    useCase = UploadPfpFromUrlUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.uploadPfpFromUrl('http://x/i.jpg')).thenAnswer((_) async => {'ok': true});

    expect(await useCase('http://x/i.jpg'), {'ok': true});

    verify(() => repository.uploadPfpFromUrl('http://x/i.jpg')).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.uploadPfpFromUrl('http://x/i.jpg')).thenThrow(Exception('boom'));

    expect(() => useCase('http://x/i.jpg'), throwsException);
  });
}
