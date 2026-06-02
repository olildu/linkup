import 'package:bloc/bloc.dart';
import 'package:linkup/domain/entities/match_candidate_entity.dart';
import 'package:linkup/domain/use_cases/user/get_other_profile_use_case.dart';
import 'package:meta/meta.dart';

part 'other_profile_event.dart';
part 'other_profile_state.dart';

class OtherProfileBloc extends Bloc<OtherProfileEvent, OtherProfileState> {
  final GetOtherProfileUseCase _getOtherProfile;

  OtherProfileBloc({required GetOtherProfileUseCase getOtherProfileUseCase})
      : _getOtherProfile = getOtherProfileUseCase,
        super(OtherProfileInitial()) {
    on<LoadOtherProfileEvent>((event, emit) async {
      emit(OtherProfileLoading());
      try {
        final user = await _getOtherProfile(event.userId);
        emit(OtherProfileLoaded(user: user));
      } catch (e) {
        emit(OtherProfileError());
      }
    });
  }
}
