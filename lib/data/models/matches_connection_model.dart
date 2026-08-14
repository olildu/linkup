class MatchesConnectionModel {
  final int id;
  final String username;
  final Map profilePictureMetaData;

  MatchesConnectionModel({
    required this.id,
    required this.username,
    required this.profilePictureMetaData,
  });

  factory MatchesConnectionModel.fromJson(Map<String, dynamic> json) {
    return MatchesConnectionModel(
      id: json['id'],
      username: json['username'],
      profilePictureMetaData: json['profile_picture'],
    );
  }
}
