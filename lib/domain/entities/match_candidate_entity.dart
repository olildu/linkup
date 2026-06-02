class MatchCandidateEntity {
  final int id;
  final String username;
  final String gender;
  final int universityId;
  final Map profilePictureMetaData;
  final DateTime dob;
  final String universityMajor;
  final int universityYear;
  final List<Map> photos;
  final String about;
  final String currentlyStaying;
  final String hometown;
  final int? height;
  final int? weight;
  final String? religion;
  final String? smokingInfo;
  final String? drinkingInfo;
  final String? lookingFor;

  const MatchCandidateEntity({
    required this.id,
    required this.username,
    required this.gender,
    required this.universityId,
    required this.profilePictureMetaData,
    required this.dob,
    required this.universityMajor,
    required this.universityYear,
    required this.photos,
    required this.about,
    required this.currentlyStaying,
    required this.hometown,
    this.height,
    this.weight,
    this.religion,
    this.smokingInfo,
    this.drinkingInfo,
    this.lookingFor,
  });
}
