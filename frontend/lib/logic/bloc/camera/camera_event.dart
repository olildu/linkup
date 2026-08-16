part of 'camera_bloc.dart';

@immutable
abstract class CameraEvent {}

class CameraInitEvent extends CameraEvent {}

class CameraSwitchEvent extends CameraEvent {}

class CameraTakePictureEvent extends CameraEvent {}

class CameraGalleryPictureEvent extends CameraEvent {}

class CameraSavePictureEvent extends CameraEvent {
  final XFile imageFile;
  CameraSavePictureEvent({required this.imageFile});
}
