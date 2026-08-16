part of 'other_profile_bloc.dart';

@immutable
sealed class OtherProfileEvent {}

class LoadOtherProfileEvent extends OtherProfileEvent {
  final int userId;
  LoadOtherProfileEvent(this.userId);
}
