import 'package:bloc/bloc.dart';
import 'package:linkup/core/enums/otp_subject_enum.dart';
import 'package:linkup/core/errors/error_message_mapper.dart';
import 'package:linkup/domain/use_cases/auth/send_otp_use_case.dart';
import 'package:linkup/domain/use_cases/auth/verify_otp_use_case.dart';
import 'package:meta/meta.dart';

part 'otp_event.dart';
part 'otp_state.dart';

class OtpBloc extends Bloc<OtpBlocEvent, OtpState> {
  final SendOTPUseCase _sendOTP;
  final VerifyOTPUseCase _verifyOTP;

  OtpBloc({
    required SendOTPUseCase sendOTPUseCase,
    required VerifyOTPUseCase verifyOTPUseCase,
  })  : _sendOTP = sendOTPUseCase,
        _verifyOTP = verifyOTPUseCase,
        super(OtpInitial()) {
    on<SendOTPEvent>((event, emit) async {
      emit(OtpLoading());
      try {
        final code = await _sendOTP(event.email);
        if (code == 200) {
          emit(OtpSent());
        } else {
          emit(OtpFailure(message: 'Failed to send OTP'));
        }
      } catch (e) {
        emit(OtpFailure(message: friendlyErrorMessage(e)));
      }
    });

    on<VerifyOTPEvent>((event, emit) async {
      emit(OtpLoading());
      try {
        final res = await _verifyOTP(event.email, event.otp, event.subject);
        emit(OtpVerified(emailHash: res['email_hash']));
      } catch (e) {
        emit(OtpFailure(message: friendlyErrorMessage(e)));
      }
    });
  }
}
