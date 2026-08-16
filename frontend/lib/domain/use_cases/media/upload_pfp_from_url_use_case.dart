import 'package:linkup/domain/repositories/media_repository.dart';

class UploadPfpFromUrlUseCase {
  final MediaRepository _repository;
  const UploadPfpFromUrlUseCase(this._repository);

  Future<Map<String, dynamic>> call(String imageUrl) =>
      _repository.uploadPfpFromUrl(imageUrl);
}
