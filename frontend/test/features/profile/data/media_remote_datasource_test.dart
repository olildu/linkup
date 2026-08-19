import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/features/profile/data/media_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockCustomHttpClient client;
  late MediaRemoteDatasource ds;
  late File tempFile;

  setUpAll(registerCommonFallbacks);
  setUp(() async {
    client = MockCustomHttpClient();
    ds = MediaRemoteDatasource(client);
    tempFile = File(
        '${Directory.systemTemp.path}/media_ds_test_${DateTime.now().microsecondsSinceEpoch}.png');
    await tempFile.writeAsBytes([1, 2, 3]);
  });

  tearDown(() async {
    if (await tempFile.exists()) await tempFile.delete();
  });

  void stubMultipart(String path, {int status = 200}) {
    when(() => client.postMultipart(
          any(),
          fields: any(named: 'fields'),
          buildFiles: any(named: 'buildFiles'),
        )).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.single as Uri;
      expect(uri.path, endsWith(path));
      // Execute buildFiles so the file-assembly closure is covered.
      final buildFiles = invocation.namedArguments[#buildFiles]
          as Future<List<http.MultipartFile>> Function();
      await buildFiles();
      return http.Response(jsonEncode({'file_key': 'k'}), status);
    });
  }

  test('uploadChatMedia posts multipart to /upload/media', () async {
    stubMultipart('/upload/media');
    final result = await ds.uploadChatMedia(tempFile, MessageType.image);
    expect(result['file_key'], 'k');

    stubMultipart('/upload/media', status: 500);
    expect(() => ds.uploadChatMedia(tempFile, MessageType.image),
        throwsException);
  });

  test('uploadUserMedia posts multipart to /upload/media-user', () async {
    stubMultipart('/upload/media-user');
    expect(await ds.uploadUserMedia(tempFile, MessageType.image),
        {'file_key': 'k'});

    stubMultipart('/upload/media-user', status: 500);
    expect(() => ds.uploadUserMedia(tempFile, MessageType.image),
        throwsException);
  });

  test('uploadPfp posts multipart to /upload/media-user-pfp', () async {
    stubMultipart('/upload/media-user-pfp');
    expect(await ds.uploadPfp(tempFile, MessageType.image), {'file_key': 'k'});

    stubMultipart('/upload/media-user-pfp', status: 500);
    expect(() => ds.uploadPfp(tempFile, MessageType.image), throwsException);
  });

  test('uploadPfpFromUrl sends the image_url field with no files', () async {
    when(() => client.postMultipart(
          any(),
          fields: any(named: 'fields'),
          buildFiles: any(named: 'buildFiles'),
        )).thenAnswer((invocation) async {
      expect(invocation.namedArguments[#fields],
          {'image_url': 'http://x/i.jpg'});
      final buildFiles = invocation.namedArguments[#buildFiles]
          as Future<List<http.MultipartFile>> Function();
      expect(await buildFiles(), isEmpty);
      return http.Response(jsonEncode({'ok': true}), 200);
    });

    expect(await ds.uploadPfpFromUrl('http://x/i.jpg'), {'ok': true});

    when(() => client.postMultipart(
          any(),
          fields: any(named: 'fields'),
          buildFiles: any(named: 'buildFiles'),
        )).thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.uploadPfpFromUrl('http://x/i.jpg'), throwsException);
  });
}
