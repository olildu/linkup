part of 'camera_bloc.dart';

@immutable
abstract class CameraState {}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraLoaded extends CameraState {
  final CameraController controller;
  final List<CameraDescription> cameras;
  final int selectedIndex;

  CameraLoaded({
    required this.controller,
    required this.cameras,
    required this.selectedIndex,
  });
}

class MediaCaptureSuccess extends CameraState {
  final XFile mediaFile;
  final double aspectRatio;
  final bool takenFromFrontCamera;
  final double height;
  final double width;

  MediaCaptureSuccess({
    required this.mediaFile,
    required this.aspectRatio,
    required this.takenFromFrontCamera,
    required this.height,
    required this.width,
  });
}

class CameraError extends CameraState {
  final String message;

  CameraError(this.message);
}
