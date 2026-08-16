part of 'preferences_bloc.dart';

@immutable
sealed class PreferencesEvent {}

final class PreferencesLoadEvent extends PreferencesEvent {}

final class PreferencesUpdateEvent extends PreferencesEvent {
  final UserPreferenceEntity userPreference;

  PreferencesUpdateEvent({required this.userPreference});
}
