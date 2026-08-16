class MatchCandidateModel {
  final int id;
  final String username;
  final String gender; // "Male" or "Female"
  final int universityId;
  final Map profilePictureMetaData;

  final DateTime dob;

  final String universityMajor;
  final int universityYear;

  final List<Map> photos;
  final String about;

  final String currentlyStaying; // "Campus Hostel", "PG", etc.
  final String hometown;

  final int? height;
  final int? weight;

  final String? religion; // "Islam", "Sikhism", ...

  final String? smokingInfo; // "Yes", "Trying to quit", ...
  final String? drinkingInfo; // "Yes", "Trying to quit", ...

  final String? lookingFor; // "Casual", "Serious", ...

  MatchCandidateModel({
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

  factory MatchCandidateModel.fromJson(Map<String, dynamic> json) {
    return MatchCandidateModel(
      id: json['id'] as int,
      username: json['username'] as String,
      gender: json['gender'] as String,
      universityId: json['university_id'] as int,
      profilePictureMetaData: json['profile_picture'] as Map,
      dob: DateTime.parse(json['dob'] as String),
      universityMajor: json['university_major'] as String,
      universityYear: json['university_year'] as int,
      photos: List<Map<String, dynamic>>.from(
        (json['photos'] ?? []).map((e) => Map<String, dynamic>.from(e)),
      ),
      about: json['about'] as String,
      currentlyStaying: json['currently_staying'] as String,
      hometown: json['hometown'] as String,
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      religion: json['religion'] as String?,
      smokingInfo: json['smoking_info'] as String?,
      drinkingInfo: json['drinking_info'] as String?,
      lookingFor: json['looking_for'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'gender': gender,
      'university_id': universityId,
      'profile_picture': profilePictureMetaData,
      'dob': dob.toIso8601String(),
      'university_major': universityMajor,
      'university_year': universityYear,
      'photos': photos,
      'about': about,
      'currently_staying': currentlyStaying,
      'hometown': hometown,
      'height': height,
      'weight': weight,
      'religion': religion,
      'smoking_info': smokingInfo,
      'drinking_info': drinkingInfo,
      'looking_for': lookingFor,
    }..removeWhere((key, data) => data == null);
  }
}
