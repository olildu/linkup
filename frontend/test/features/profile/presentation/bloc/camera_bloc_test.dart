import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkup/features/profile/presentation/bloc/camera_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockCameraController extends Mock implements CameraController {}

class MockImagePicker extends Mock implements ImagePicker {}

const backCamera = CameraDescription(
  name: 'back',
  lensDirection: CameraLensDirection.back,
  sensorOrientation: 0,
);
const frontCamera = CameraDescription(
  name: 'front',
  lensDirection: CameraLensDirection.front,
  sensorOrientation: 0,
);

class MockCameraValue extends Mock implements CameraValue {}

CameraValue loadedValue() {
  final value = MockCameraValue();
  when(() => value.aspectRatio).thenReturn(9 / 16);
  when(() => value.previewSize).thenReturn(const Size(1080, 1920));
  return value;
}

void main() {
  late MockCameraController controller;
  late MockImagePicker picker;
  late Directory tempDir;

  setUp(() async {
    controller = MockCameraController();
    picker = MockImagePicker();
    tempDir = await Directory.systemTemp.createTemp('camera_bloc_test');
    when(() => controller.initialize()).thenAnswer((_) async {});
    when(() => controller.dispose()).thenAnswer((_) async {});
    final value = loadedValue();
    when(() => controller.value).thenReturn(value);
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  CameraBloc build({
    List<CameraDescription> cameras = const [backCamera, frontCamera],
    Future<XFile?> Function(String, String)? compressFn,
    Future<void> Function(String)? saveFn,
  }) =>
      CameraBloc(
        availableCamerasFn: () async => cameras,
        controllerFactory: (_, __) => controller,
        picker: picker,
        compressFn: compressFn ?? (src, dst) async => XFile(src),
        saveToGalleryFn: saveFn ?? (_) async {},
        tempDirFn: () async => tempDir,
      );

  Future<void> pump([int ms = 10]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  test('init emits Loading then Loaded with the first camera', () async {
    final bloc = build();
    final states = <CameraState>[];
    bloc.stream.listen(states.add);

    bloc.add(CameraInitEvent());
    await pump();

    expect(states, [isA<CameraLoading>(), isA<CameraLoaded>()]);
    expect((states.last as CameraLoaded).selectedIndex, 0);
    await bloc.close();
  });

  test('init failure emits CameraError', () async {
    final bloc = CameraBloc(
      availableCamerasFn: () async => throw CameraException('no', 'cameras'),
      controllerFactory: (_, __) => controller,
      picker: picker,
      compressFn: (src, dst) async => XFile(src),
      saveToGalleryFn: (_) async {},
      tempDirFn: () async => tempDir,
    );
    bloc.add(CameraInitEvent());
    await pump();
    expect(bloc.state, isA<CameraError>());
    await bloc.close();
  });

  test('switch cycles to the next camera; single camera is a no-op',
      () async {
    final bloc = build();
    bloc.add(CameraInitEvent());
    await pump();
    bloc.add(CameraSwitchEvent());
    await pump();
    expect((bloc.state as CameraLoaded).selectedIndex, 1);
    await bloc.close();

    final single = build(cameras: const [backCamera]);
    single.add(CameraInitEvent());
    await pump();
    single.add(CameraSwitchEvent());
    await pump();
    expect((single.state as CameraLoaded).selectedIndex, 0);
    await single.close();
  });

  test('take picture compresses and emits MediaCaptureSuccess', () async {
    final captured = File('${tempDir.path}/raw.jpg')..writeAsBytesSync([1]);
    when(() => controller.takePicture())
        .thenAnswer((_) async => XFile(captured.path));

    final bloc = build();
    bloc.add(CameraInitEvent());
    await pump();
    bloc.add(CameraTakePictureEvent());
    await pump();

    final state = bloc.state as MediaCaptureSuccess;
    expect(state.mediaFile.path, captured.path);
    expect(state.takenFromFrontCamera, isFalse);
    await bloc.close();
  });

  test('compression failure emits CameraError', () async {
    when(() => controller.takePicture())
        .thenAnswer((_) async => XFile('${tempDir.path}/raw.jpg'));
    final bloc = build(compressFn: (_, __) async => null);
    bloc.add(CameraInitEvent());
    await pump();
    bloc.add(CameraTakePictureEvent());
    await pump();
    expect((bloc.state as CameraError).message, 'Image compression failed');
    await bloc.close();
  });

  test('gallery pick emits MediaCaptureSuccess; cancel is a no-op', () async {
    when(() => picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 50,
        )).thenAnswer((_) async => XFile('/tmp/picked.png'));

    final bloc = build();
    bloc.add(CameraGalleryPictureEvent());
    await pump();
    expect(bloc.state, isA<MediaCaptureSuccess>());
    await bloc.close();

    when(() => picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 50,
        )).thenAnswer((_) async => null);
    final cancelled = build();
    cancelled.add(CameraGalleryPictureEvent());
    await pump();
    expect(cancelled.state, isA<CameraInitial>());
    await cancelled.close();
  });

  test('save picture writes existing files and errors on missing ones',
      () async {
    final saved = <String>[];
    final file = File('${tempDir.path}/save.jpg')..writeAsBytesSync([1]);

    final bloc = build(saveFn: (path) async => saved.add(path));
    bloc.add(CameraSavePictureEvent(imageFile: XFile(file.path)));
    await pump();
    expect(saved, [file.path]);

    bloc.add(CameraSavePictureEvent(imageFile: XFile('/nope/missing.jpg')));
    await pump();
    expect((bloc.state as CameraError).message, 'File does not exist');
    await bloc.close();
  });
}
