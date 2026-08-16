import 'package:linkup/features/profile/domain/media_repository.dart';

class UploadPfpFromUrlUseCase {
  final MediaRepository _repository;
  const UploadPfpFromUrlUseCase(this._repository);

  Future<Map<String, dynamic>> call(String imageUrl) =>
      _repository.uploadPfpFromUrl(imageUrl);
}
