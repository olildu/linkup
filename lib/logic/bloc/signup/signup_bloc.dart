import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/data/data_parser/signup_page/data_parser.dart';
import 'package:linkup/domain/use_cases/media/upload_pfp_use_case.dart';
import 'package:linkup/domain/use_cases/media/upload_user_media_use_case.dart';
import 'package:linkup/presentation/constants/singup_page/flow.dart';
import 'package:meta/meta.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  late SignUpPageFlow _signUpPageFlow;
  int _currentIndex = 0;
  int _progressBarIndex = 0;

  final bool isSigningUp;
  final UploadPfpUseCase _uploadPfp;
  final UploadUserMediaUseCase _uploadUserMedia;

  SignupBloc({
    required UploadPfpUseCase uploadPfpUseCase,
    required UploadUserMediaUseCase uploadUserMediaUseCase,
    this.isSigningUp = true,
  }) : _uploadPfp = uploadPfpUseCase,
       _uploadUserMedia = uploadUserMediaUseCase,
       super(SignupInitial(currentIndex: 0, progessBarIndex: 0)) {
    on<SignupInit>((event, emit) async {
      _signUpPageFlow = event.signUpPageFlow;
      _currentIndex = event.currentIndex;

      add(SignupNext());
    });

    on<SignupNext>((event, emit) async {
      if (_currentIndex == 9) {
        await _uploadPhotos(emit);
        return;
      }

      bool isAtEnd = _currentIndex == _signUpPageFlow.flow.length - 1;

      // User at end complete upload
      if (isAtEnd) {
        add(SignupUpload());
        return;
      }

      _currentIndex++;
      if (_signUpPageFlow.flow[_currentIndex]["showProgressBar"] == null) {
        _progressBarIndex = _signUpPageFlow.flow[_currentIndex]["index"];
      }

      if (_currentIndex > 11 && !isAtEnd) {
        emit(
          SignupInitial(
            buttonText: "Skip",
            currentIndex: _currentIndex,
            progessBarIndex: _progressBarIndex,
          ),
        );
      } else if (_currentIndex == 9) {
        emit(
          SignupInitial(
            buttonText: "Upload Photos",
            currentIndex: _currentIndex,
            progessBarIndex: _progressBarIndex,
          ),
        );
      } else if (!isAtEnd) {
        emit(
          SignupInitial(
            buttonText: "Next",
            currentIndex: _currentIndex,
            progessBarIndex: _progressBarIndex,
          ),
        );
      }
    });

    on<SignupPrevious>((event, emit) async {
      if (_currentIndex <= 0) {
        return;
      }

      _currentIndex--;
      if (_signUpPageFlow.flow[_currentIndex]["showProgressBar"] == null) {
        _progressBarIndex = _signUpPageFlow.flow[_currentIndex]["index"];
      }

      if (_currentIndex > 11) {
        emit(
          SignupInitial(
            buttonText: "Skip",
            currentIndex: _currentIndex,
            progessBarIndex: _progressBarIndex,
          ),
        );
      } else if (_currentIndex == 9) {
        emit(
          SignupInitial(
            buttonText: "Upload Photos",
            currentIndex: _currentIndex,
            progessBarIndex: _progressBarIndex,
          ),
        );
      } else {
        emit(
          SignupInitial(
            buttonText: "Next",
            currentIndex: _currentIndex,
            progessBarIndex: _progressBarIndex,
          ),
        );
      }
    });

    on<SignupOptionalFilled>((event, emit) async {
      if (_currentIndex > 11) {
        bool isAtEnd = _currentIndex == _signUpPageFlow.flow.length - 1;
        emit(
          SignupInitial(
            buttonText: isAtEnd ? "Finish" : "Next",
            currentIndex: _currentIndex,
            progessBarIndex: _progressBarIndex,
          ),
        );
      }
    });

    on<SignupUpload>((event, emit) async {
      try {
        if (!isSigningUp) {
          emit(UpdateComplete());
          return;
        }

        emit(SingupUploading());
        // Submit
        await SignUpDataParser.submitRegistration();
        await Future.delayed(Duration(seconds: 2));
        // Show Animation
        emit(SingupUploading(uploadComplete: true));

        await Future.delayed(Duration(seconds: 3));
        emit(SingupUploaded());
      } on Exception catch (_) {
        emit(SingupUploadError(message: "Failed to upload, try again later."));
      }
    });
  }

  Future<void> _uploadPhotos(Emitter<SignupState> emit) async {
    if (SignUpDataParser.data.photos != null &&
        SignUpDataParser.data.photos!.isNotEmpty &&
        isSigningUp) {
      emit(SingupPhotoUploading());

      try {
        // Upload first user photo and retrieve user pfp from here
        final firstImageDataRes = await _uploadPfp(
          File(SignUpDataParser.data.photos![0].path),
          MessageType.image,
        );

        if (firstImageDataRes['status'] != 'failed') {
          final futures = SignUpDataParser.data.photos!
              .asMap()
              .entries
              .where((entry) => entry.key != 0)
              .map((entry) async {
                final photo = entry.value;
                final result = await _uploadUserMedia(
                  File(photo.path),
                  MessageType.image,
                );
                return result['metadata'] as Map;
              })
              .toList();

          List<Map> uploadedUrls = await Future.wait(futures);
          uploadedUrls.insert(0, firstImageDataRes["original_image_metadata"]);
          SignUpDataParser.updateField(photos: uploadedUrls);
          SignUpDataParser.updateField(
            profilePicture: firstImageDataRes['profile_metadata'],
          );

          emit(SingupPhotoUploaded());

          // Now increment index and emit new state
          _currentIndex++;
          if (_signUpPageFlow.flow[_currentIndex]["showProgressBar"] == null) {
            _progressBarIndex = _signUpPageFlow.flow[_currentIndex]["index"];
          }

          emit(
            SignupInitial(
              buttonText: "Next",
              currentIndex: _currentIndex,
              progessBarIndex: _progressBarIndex,
            ),
          );
        } else {
          emit(
            SingupPhotoUploadError(
              message:
                  'Face not detected or multiple faces detected in the first image.',
            ),
          );
          emit(
            SignupInitial(
              buttonText: "Retry Upload",
              currentIndex: _currentIndex,
              progessBarIndex: _progressBarIndex,
            ),
          );
        }
      } catch (e, stackTree) {
        log('Photo upload error: $e\n$stackTree');
        emit(SingupPhotoUploadError(message: 'Some error occured, try again.'));
        emit(
          SignupInitial(
            buttonText: "Retry Upload",
            currentIndex: _currentIndex,
            progessBarIndex: _progressBarIndex,
          ),
        );
      }
    } else {
      emit(
        SignupInitial(
          buttonText: "Upload Photos",
          currentIndex: _currentIndex,
          progessBarIndex: _progressBarIndex - 1,
        ),
      );
    }
  }
}
