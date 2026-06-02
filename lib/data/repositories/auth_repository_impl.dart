import 'package:shared_preferences/shared_preferences.dart';
import 'package:linkup/core/enums/otp_subject_enum.dart';
import 'package:linkup/core/network/token_service.dart';
import 'package:linkup/data/datasources/remote/auth_remote_datasource.dart';
import 'package:linkup/data/datasources/remote/user_remote_datasource.dart';
import 'package:linkup/data/models/update_metadata_model.dart';
import 'package:linkup/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _authDatasource;
  final UserRemoteDatasource _userDatasource;
  final TokenService _tokenService;

  static const _appLockKey = 'app_lock_enabled';

  const AuthRepositoryImpl({
    required AuthRemoteDatasource authDatasource,
    required UserRemoteDatasource userDatasource,
    required TokenService tokenService,
  })  : _authDatasource = authDatasource,
        _userDatasource = userDatasource,
        _tokenService = tokenService;

  @override
  Future<void> login(String email, String password) async {
    final result = await _authDatasource.login(email, password);
    await _tokenService.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      userId: result.userId,
    );
  }

  @override
  Future<void> register(String emailHash, String password) async {
    final result = await _authDatasource.register(emailHash, password);
    await _tokenService.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      userId: result.userId,
    );
  }

  @override
  Future<void> resetPassword(String emailHash, String password) async {
    await _authDatasource.resetPassword(emailHash, password);
  }

  @override
  Future<int> sendEmailOTP(String email) =>
      _authDatasource.sendEmailOTP(email);

  @override
  Future<Map<String, dynamic>> verifyEmailOTP(
    String email,
    int otp,
    EmailOTPSubject subject,
  ) =>
      _authDatasource.verifyEmailOTP(email, otp, subject);

  @override
  Future<bool> completeProfile(UpdateMetadataModel data) =>
      _authDatasource.completeProfile(data);

  @override
  Future<void> logout() async {
    await _tokenService.clearTokens();
    await _clearAppLock();
  }

  @override
  Future<void> deleteAccount() async {
    await _userDatasource.deleteAccount();
    await _tokenService.clearTokens();
    await _clearAppLock();
  }

  Future<void> _clearAppLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appLockKey);
  }
}
