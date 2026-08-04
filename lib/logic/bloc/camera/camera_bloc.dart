import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:linkup/core/errors/error_message_mapper.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  static const String _logTag = 'CameraBloc';

  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedIndex = 0;
  double _aspectRatio = 3 / 4;
  double _height = 0.0;
  double _width = 0.0;

  bool _imageProcessing = false;

  CameraBloc() : super(CameraInitial()) {
    on<CameraInitEvent>((event, emit) async {
      emit(CameraLoading());
      try {
        _cameras = await availableCameras();
        _imageProcessing = false;

        log('Cameras available: ${_cameras.length}', name: _logTag);

        _selectedIndex = 0;
        _controller = CameraController(_cameras[_selectedIndex], ResolutionPreset.max);
        await _controller!.initialize();

        _aspectRatio = _controller!.value.aspectRatio;
        _height = _controller!.value.previewSize!.height;
        _width = _controller!.value.previewSize!.width;

        emit(CameraLoaded(controller: _controller!, cameras: _cameras, selectedIndex: _selectedIndex));
        log('Camera initialized successfully', name: _logTag);
      } catch (e, st) {
        log('Camera init failed: $e', name: _logTag, stackTrace: st);
        emit(CameraError(friendlyErrorMessage(e)));
      }
    });

    on<CameraSwitchEvent>((event, emit) async {
      if (_cameras.length < 2) return;
      emit(CameraLoading());
      try {
        _selectedIndex = (_selectedIndex + 1) % _cameras.length;
        await _controller?.dispose();

        _controller = CameraController(_cameras[_selectedIndex], ResolutionPreset.max);
        await _controller!.initialize();

        _aspectRatio = _controller!.value.aspectRatio;

        emit(CameraLoaded(controller: _controller!, cameras: _cameras, selectedIndex: _selectedIndex));
        log('Switched to camera index $_selectedIndex', name: _logTag);
      } catch (e, st) {
        log('Camera switch failed: $e', name: _logTag, stackTrace: st);
        emit(CameraError(friendlyErrorMessage(e)));
      }
    });

    on<CameraTakePictureEvent>((event, emit) async {
      try {
        if (_imageProcessing) return;

        _imageProcessing = true;
        final imageFile = await _controller?.takePicture();
        if (imageFile == null) {
          log('Failed to capture image', name: _logTag);
          emit(CameraError("Failed to capture image"));
          return;
        }

        final tempDir = await getTemporaryDirectory();
        final targetPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        final compressedImage = await FlutterImageCompress.compressAndGetFile(imageFile.path, targetPath, quality: 50, format: CompressFormat.jpeg);

        if (compressedImage == null) {
          log('Compression failed', name: _logTag);
          emit(CameraError("Image compression failed"));
          _imageProcessing = false;
          return;
        }

        emit(
          MediaCaptureSuccess(
            mediaFile: XFile(compressedImage.path),
            aspectRatio: _aspectRatio,
            takenFromFrontCamera: _cameras[_selectedIndex].lensDirection == CameraLensDirection.front,
            height: _height,
            width: _width,
          ),
        );

        log('Picture taken and compressed: ${compressedImage.path}', name: _logTag);
        await _controller?.dispose();
        _controller = null;
        _imageProcessing = false;
      } catch (e, st) {
        log('Capture failed: $e', name: _logTag, stackTrace: st);
        emit(CameraError(friendlyErrorMessage(e)));
        _imageProcessing = false;
      }
    });

    on<CameraGalleryPictureEvent>((event, emit) async {
      try {
        final imagePicker = ImagePicker();
        final imageFile = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50);

        if (imageFile == null) {
          log('No image selected', name: _logTag);
          return;
        }

        emit(MediaCaptureSuccess(mediaFile: imageFile, aspectRatio: _aspectRatio, takenFromFrontCamera: false, height: _height, width: _width));

        log('Gallery image selected: ${imageFile.path}', name: _logTag);
        _controller?.dispose();
        _controller = null;
      } catch (e, st) {
        log('Gallery pick failed: $e', name: _logTag, stackTrace: st);
        emit(CameraError(friendlyErrorMessage(e)));
      }
    });

    on<CameraSavePictureEvent>((event, emit) async {
      try {
        final file = File(event.imageFile.path);
        if (await file.exists()) {
          await Gal.putImage(file.path);
          log('Saved image to gallery: ${file.path}', name: _logTag);
        } else {
          log('File does not exist: ${file.path}', name: _logTag);
          emit(CameraError('File does not exist'));
        }
      } catch (e, st) {
        log('Save failed: $e', name: _logTag, stackTrace: st);
        emit(CameraError(friendlyErrorMessage(e)));
      }
    });
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
