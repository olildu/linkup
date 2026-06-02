import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:linkup/domain/entities/user_preference_entity.dart';
import 'package:linkup/domain/use_cases/user/get_preference_use_case.dart';
import 'package:linkup/domain/use_cases/user/update_preference_use_case.dart';
import 'package:meta/meta.dart';

part 'preferences_event.dart';
part 'preferences_state.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final GetPreferenceUseCase _getPreference;
  final UpdatePreferenceUseCase _updatePreference;

  PreferencesBloc({
    required GetPreferenceUseCase getPreferenceUseCase,
    required UpdatePreferenceUseCase updatePreferenceUseCase,
  })  : _getPreference = getPreferenceUseCase,
        _updatePreference = updatePreferenceUseCase,
        super(PreferencesInitial()) {
    on<PreferencesLoadEvent>((event, emit) async {
      emit(PreferencesLoading());
      try {
        final preference = await _getPreference();
        emit(PreferencesLoaded(userPreference: preference));
      } catch (e) {
        log('Error loading preferences: $e');
        emit(PreferencesError());
      }
    });

    on<PreferencesUpdateEvent>((event, emit) async {
      emit(PreferencesLoaded(userPreference: event.userPreference));
      log('PreferencesUpdateEvent: ${event.userPreference}');
      try {
        await _updatePreference(event.userPreference);
      } catch (e) {
        log('Error updating preferences: $e');
      }
    });
  }
}
