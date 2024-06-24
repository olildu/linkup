import 'dart:io';
import 'dart:typed_data'; // Import this for Uint8List
import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:image/image.dart' as img;

class hasher {
  Future<Map> encode(imagePath) async {
    for (var x in imagePath.keys.toList()){
      final data = File(x.path).readAsBytesSync();
      final image = img.decodeImage(Uint8List.fromList(data)); // Convert to Uint8List if necessary
      final blurHash = BlurHash.encode(image!, numCompX: 5, numCompY: 5);
      imagePath[x].add(blurHash.hash);
    }
    return imagePath;
  }
}

