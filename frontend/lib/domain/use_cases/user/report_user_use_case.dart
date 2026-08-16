import 'package:linkup/domain/repositories/user_repository.dart';

class ReportUserUseCase {
  final UserRepository _repository;
  const ReportUserUseCase(this._repository);

  Future<void> call(int userId, String reason) =>
      _repository.reportUser(userId, reason);
}
