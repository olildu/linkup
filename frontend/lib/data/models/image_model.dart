class ImageModel {
  final String url;
  final String blurHash;

  ImageModel({required this.url, required this.blurHash});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      url: json['url'] as String,
      blurHash: json['blurhash'] as String,
    );
  }
}
