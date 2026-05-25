part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class ProfileLoadEvent extends ProfileEvent {
  final bool showLoading;
  ProfileLoadEvent({this.showLoading = false});
}

final class ProfileUpdateEvent extends ProfileEvent {
  final UpdateMetadataModel userUpdatedModel;

  ProfileUpdateEvent({required this.userUpdatedModel});
}

final class ProfileImagesUpdatedEvent extends ProfileEvent {
  final List<dynamic> selectedImages;
  final bool changePfp;

  ProfileImagesUpdatedEvent({
    required this.selectedImages,
    required this.changePfp,
  });
}