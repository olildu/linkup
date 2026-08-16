part of 'signup_bloc.dart';

@immutable
sealed class SignupState {}

final class SignupInitial extends SignupState {
  final String buttonText;
  final int currentIndex;
  final int progessBarIndex;

  SignupInitial({
    this.buttonText = "Next",
    required this.currentIndex,
    required this.progessBarIndex,
  });
}

// Photo Upload States
final class SingupPhotoUploading extends SignupState {}

final class SingupPhotoUploaded extends SignupState {}

final class SingupPhotoUploadError extends SignupState {
  final String message;
  SingupPhotoUploadError({required this.message});
}

// Final Registration Upload States
final class SingupUploading extends SignupState {
  final bool uploadComplete;
  SingupUploading({this.uploadComplete = false});
}

final class SingupUploaded extends SignupState {}

final class SingupUploadError extends SignupState {
  final String message;
  SingupUploadError({required this.message});
}

// Update States

final class UpdateComplete extends SignupState {}
