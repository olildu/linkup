class UserEntity {
  final int id;
  final String? username;
  final String? gender;
  final int universityId;
  final Map? profilePicture;
  final DateTime? dob;
  final String? interestedGender;
  final String? universityMajor;
  final int? universityYear;
  final List<Map>? photos;
  final String? about;
  final String? currentlyStaying;
  final String? hometown;
  final int? height;
  final int? weight;
  final String? religion;
  final String? smokingInfo;
  final String? drinkingInfo;
  final String? lookingFor;

  const UserEntity({
    required this.id,
    required this.universityId,
    this.username,
    this.gender,
    this.profilePicture,
    this.dob,
    this.interestedGender,
    this.universityMajor,
    this.universityYear,
    this.photos,
    this.about,
    this.currentlyStaying,
    this.hometown,
    this.height,
    this.weight,
    this.religion,
    this.smokingInfo,
    this.drinkingInfo,
    this.lookingFor,
  });
}
