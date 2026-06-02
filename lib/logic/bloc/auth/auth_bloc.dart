import 'package:bloc/bloc.dart';
import 'package:linkup/domain/use_cases/auth/delete_account_use_case.dart';
import 'package:linkup/domain/use_cases/auth/login_use_case.dart';
import 'package:linkup/domain/use_cases/auth/logout_use_case.dart';
import 'package:linkup/domain/use_cases/auth/register_use_case.dart';
import 'package:linkup/domain/use_cases/auth/reset_password_use_case.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _login;
  final LogoutUseCase _logout;
  final RegisterUseCase _register;
  final ResetPasswordUseCase _resetPassword;
  final DeleteAccountUseCase _deleteAccount;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required RegisterUseCase registerUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
  })  : _login = loginUseCase,
        _logout = logoutUseCase,
        _register = registerUseCase,
        _resetPassword = resetPasswordUseCase,
        _deleteAccount = deleteAccountUseCase,
        super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _login(event.email, event.password);
        emit(AuthAuthenticated());
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _register(event.emailHash, event.password);
        emit(AuthAuthenticated());
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<AuthResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _resetPassword(event.emailHash, event.password);
        emit(AuthAuthenticated());
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });
  }

  Future<void> logout() => _logout();

  Future<void> deleteAccount() => _deleteAccount();
}
