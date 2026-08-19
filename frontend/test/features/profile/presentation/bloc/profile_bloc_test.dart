import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkup/core/entities/update_metadata_model.dart';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockGetProfileUseCase getProfile;
  late MockUpdateProfileUseCase updateProfile;
  late MockUploadUserMediaUseCase uploadUserMedia;
  late MockUploadPfpFromUrlUseCase uploadPfpFromUrl;

  setUpAll(() {
    registerFallbackValue(UpdateMetadataModel());
    registerFallbackValue(MessageType.image);
    registerFallbackValue(File('/tmp/fallback.png'));
  });

  setUp(() {
    getProfile = MockGetProfileUseCase();
    updateProfile = MockUpdateProfileUseCase();
    uploadUserMedia = MockUploadUserMediaUseCase();
    uploadPfpFromUrl = MockUploadPfpFromUrlUseCase();
    when(() => getProfile()).thenAnswer((_) async => makeUser());
  });

  ProfileBloc build() => ProfileBloc(
        getProfileUseCase: getProfile,
        updateProfileUseCase: updateProfile,
        uploadUserMediaUseCase: uploadUserMedia,
        uploadPfpFromUrlUseCase: uploadPfpFromUrl,
      );

  Future<void> pump([int ms = 10]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  test('load emits Loading then Loaded, and Error on failure', () async {
    final bloc = build();
    final states = <ProfileState>[];
    bloc.stream.listen(states.add);

    bloc.add(ProfileLoadEvent(showLoading: true));
    await pump();
    expect(states, [isA<ProfileLoading>(), isA<ProfileLoaded>()]);
    expect((states.last as ProfileLoaded).user.username, 'me');

    when(() => getProfile()).thenThrow(Exception('down'));
    bloc.add(ProfileLoadEvent());
    await pump();
    expect(bloc.state, isA<ProfileError>());
    await bloc.close();
  });

  test('update posts the model then silently reloads', () async {
    when(() => updateProfile(any(), updatePfp: any(named: 'updatePfp')))
        .thenAnswer((_) async {});
    final bloc = build();
    bloc.add(ProfileUpdateEvent(
        userUpdatedModel: UpdateMetadataModel(about: 'new')));
    await pump();

    verify(() => updateProfile(any(), updatePfp: false)).called(1);
    expect(bloc.state, isA<ProfileLoaded>());

    when(() => updateProfile(any(), updatePfp: any(named: 'updatePfp')))
        .thenThrow(Exception('down'));
    bloc.add(ProfileUpdateEvent(
        userUpdatedModel: UpdateMetadataModel(about: 'x')));
    await pump();
    expect(bloc.state, isA<ProfileError>());
    await bloc.close();
  });

  test('image update uploads new files, keeps existing maps and sets pfp',
      () async {
    when(() => uploadUserMedia(any(), any())).thenAnswer(
        (_) async => {'metadata': {'url': 'http://cdn/new.jpg'}});
    when(() => uploadPfpFromUrl('http://cdn/new.jpg')).thenAnswer(
        (_) async => {'profile_metadata': {'url': 'http://cdn/pfp.jpg'}});
    when(() => updateProfile(any(), updatePfp: true)).thenAnswer((_) async {});

    final bloc = build();
    final states = <ProfileState>[];
    bloc.stream.listen(states.add);

    bloc.add(ProfileImagesUpdatedEvent(
      selectedImages: [XFile('/tmp/new.png'), {'url': 'http://cdn/old.jpg'}],
      changePfp: true,
    ));
    await pump(50);

    expect(states.whereType<ProfileUpdating>(), isNotEmpty);
    final sent = verify(() => updateProfile(captureAny(), updatePfp: true))
        .captured
        .single as UpdateMetadataModel;
    expect(sent.photos, hasLength(2));
    expect(sent.profilePicture, {'url': 'http://cdn/pfp.jpg'});
    expect(bloc.state, isA<ProfileLoaded>());
    await bloc.close();
  });

  test('image update failure emits ProfileError', () async {
    when(() => uploadUserMedia(any(), any())).thenThrow(Exception('too big'));
    final bloc = build();
    bloc.add(ProfileImagesUpdatedEvent(
        selectedImages: [XFile('/tmp/new.png')], changePfp: false));
    await pump(50);
    expect(bloc.state, isA<ProfileError>());
    await bloc.close();
  });
}
