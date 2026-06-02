part of 'preferences_bloc.dart';

@immutable
sealed class PreferencesState {}

final class PreferencesInitial extends PreferencesState {}

final class PreferencesLoading extends PreferencesState {}

final class PreferencesLoaded extends PreferencesState {
  final UserPreferenceEntity userPreference;
  PreferencesLoaded({required this.userPreference});
}

final class PreferencesError extends PreferencesState {}
