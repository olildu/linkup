import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/core/entities/update_metadata_model.dart';
import 'package:linkup/features/profile/domain/user_entity.dart';
import 'package:linkup/features/profile/domain/upload_pfp_from_url_use_case.dart';
import 'package:linkup/features/profile/domain/upload_user_media_use_case.dart';
import 'package:linkup/features/profile/domain/get_profile_use_case.dart';
import 'package:linkup/features/profile/domain/update_profile_use_case.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;
  final UploadUserMediaUseCase _uploadUserMedia;
  final UploadPfpFromUrlUseCase _uploadPfpFromUrl;

  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UploadUserMediaUseCase uploadUserMediaUseCase,
    required UploadPfpFromUrlUseCase uploadPfpFromUrlUseCase,
  }) : _getProfile = getProfileUseCase,
       _updateProfile = updateProfileUseCase,
       _uploadUserMedia = uploadUserMediaUseCase,
       _uploadPfpFromUrl = uploadPfpFromUrlUseCase,
       super(ProfileInitial()) {
    on<ProfileLoadEvent>((event, emit) async {
      if (event.showLoading) emit(ProfileLoading());
      log('Loading profile details');
      try {
        final user = await _getProfile();
        emit(ProfileLoaded(user: user));
      } on Exception catch (e) {
        log('Error loading profile: $e');
        emit(ProfileError());
      }
    });

    on<ProfileUpdateEvent>((event, emit) async {
      try {
        await _updateProfile(event.userUpdatedModel);
        add(ProfileLoadEvent(showLoading: false));
      } on Exception catch (e) {
        log('Error updating profile: $e');
        emit(ProfileError());
      }
    });

    on<ProfileImagesUpdatedEvent>((event, emit) async {
      try {
        final uploadItems = event.selectedImages.whereType<XFile>().toList();
        List<Map> finalImages = [];
        int uploadedCount = 0;
        Map? pfpMetadata;

        emit(
          uploadItems.isEmpty
              ? ProfileUpdating(
                  current: 0,
                  total: 0,
                  message: 'Saving changes...',
                )
              : ProfileUpdating(
                  current: 0,
                  total: uploadItems.length,
                  message: 'Preparing upload...',
                ),
        );

        for (final item in event.selectedImages) {
          if (item is XFile) {
            uploadedCount++;
            emit(
              ProfileUpdating(
                current: uploadedCount,
                total: uploadItems.length,
                message: 'Uploading photos...',
              ),
            );
            final uploaded = await _uploadUserMedia(
              File(item.path),
              MessageType.image,
            );
            finalImages.add(uploaded['metadata']);
          } else {
            finalImages.add(item as Map);
          }
        }

        emit(
          ProfileUpdating(
            current: finalImages.length,
            total: finalImages.length,
            message: 'Processing profile picture...',
          ),
        );

        if (event.changePfp) {
          final first = finalImages.isNotEmpty ? finalImages.first : null;
          if (first != null && first['url'] != null) {
            pfpMetadata = await _uploadPfpFromUrl(first['url'] as String);
          }
        }

        await _updateProfile(
          UpdateMetadataModel(
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
