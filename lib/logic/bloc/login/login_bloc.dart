import 'package:bloc/bloc.dart';
import 'package:linkup/domain/use_cases/auth/login_use_case.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _login;

  LoginBloc({required LoginUseCase loginUseCase})
      : _login = loginUseCase,
        super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        await _login(event.email, event.password);
        emit(LoginSuccess());
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('401') || msg.contains('Invalid')) {
          emit(LoginFailure(errorMessage: 'Invalid email or password'));
        } else {
          emit(LoginFailure(errorMessage: 'Connection error. Please check your internet.'));
        }
      }
    });
  }
}
