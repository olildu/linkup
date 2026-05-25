import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkup/data/enums/message_type_enum.dart';
import 'package:linkup/data/http_services/common_http_services/common_http_services.dart';
import 'package:linkup/data/http_services/user_http_services/user_http_services.dart';
import 'package:linkup/data/models/update_metadata_model.dart';
import 'package:linkup/data/models/user_model.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileLoadEvent>((event, emit) async {
      if (event.showLoading) {
        emit(ProfileLoading());
      }
      log("Loading profile details");
      try {
        final UserModel user = await UserHttpServices().getProfileSettings();
        emit(ProfileLoaded(user: user));
      } on Exception catch (e) {
        log('Error loading profile: $e');
        emit(ProfileError());
      }
    });

    on<ProfileUpdateEvent>((event, emit) async {
      try {
        await UserHttpServices().updateUserProfile(userUpdatedModel: event.userUpdatedModel);

        add(ProfileLoadEvent(showLoading: false));
      } on Exception catch (e) {
        log('Error loading profile: $e');
        emit(ProfileError());
      }
    });

    on<ProfileImagesUpdatedEvent>((event, emit) async {
      try {
        final uploadItems = event.selectedImages.whereType<XFile>().toList();
        List<Map> finalImages = [];
        int uploadedCount = 0;
        Map? pfpMetadata;

        if (uploadItems.isEmpty) {
          emit(ProfileUpdating(current: 0, total: 0, message: "Saving changes..."));
        } else {
          emit(
            ProfileUpdating(current: 0, total: uploadItems.length, message: "Preparing upload..."),
          );
        }

        for (final item in event.selectedImages) {
          if (item is XFile) {
            uploadedCount++;

            emit(
              ProfileUpdating(
                current: uploadedCount,
                total: uploadItems.length,
                message: "Uploading photos...",
              ),
            );

            final uploaded = await CommonHttpServices().uploadMediaUser(
              file: File(item.path),
              mediaType: MessageType.image,
            );

            finalImages.add(uploaded['metadata']);
          } else {
            finalImages.add(item);
          }
        }

        emit(
          ProfileUpdating(
            current: finalImages.length,
            total: finalImages.length,
            message: "Processing profile picture...",
          ),
        );

        if (event.changePfp) {
          final firstImage = finalImages.isNotEmpty ? finalImages.first : null;

          if (firstImage != null && firstImage['url'] != null) {
            pfpMetadata = await CommonHttpServices().uploadProfilePictureFromUrl(
              imageUrl: firstImage['url'],
            );
          }
        }

        await UserHttpServices().updateUserProfile(
          userUpdatedModel: UpdateMetadataModel(
            photos: finalImages,
            profilePicture: pfpMetadata?['profile_metadata'],
          ),
          updatePfp: event.changePfp,
        );

        add(ProfileLoadEvent(showLoading: false));
      } catch (e) {
        log('Error updating profile images: $e');
        emit(ProfileError());
      }
    });
  }
}
