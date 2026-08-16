import 'package:linkup/features/profile/domain/user_entity.dart';

class UpdateMetadataModel {
  // Core
  final String? universityMajor;
  final int? universityYear;

  final String? username;
  final DateTime? dob;
  final String? gender;

  final Map? profilePicture;
  final List<dynamic>? photos;

  final String? about;

  final String? currentlyStaying;
  final String? hometown;

  // Interests
  final int? height;
  final int? weight;

  final String? interestedGender;

  final String? religion;

  final String? smokingInfo;
  final String? drinkingInfo;

  final String? lookingFor;

  UpdateMetadataModel({
    this.universityMajor,
    this.universityYear,
    this.username,
    this.dob,
    this.gender,
    this.photos,
    this.interestedGender,
    this.profilePicture,
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

  factory UpdateMetadataModel.fromUserEntity(UserEntity user) {
    return UpdateMetadataModel(
      universityMajor: user.universityMajor,
      universityYear: user.universityYear,
      username: user.username,
      dob: user.dob,
      gender: user.gender,
      interestedGender: user.interestedGender,
      profilePicture: user.profilePicture,
      photos: user.photos,
      about: user.about,
      currentlyStaying: user.currentlyStaying,
      hometown: user.hometown,
      height: user.height,
      weight: user.weight,
      religion: user.religion,
      smokingInfo: user.smokingInfo,
      drinkingInfo: user.drinkingInfo,
      lookingFor: user.lookingFor,
    );
  }

  factory UpdateMetadataModel.fromJson(Map<String, dynamic> json) {
    return UpdateMetadataModel(
      universityMajor: json['university_major'] as String?,
      universityYear: json['university_year'] as int?,
      username: json['username'] as String?,
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      gender: json['gender'] as String?,
      interestedGender: json['interested_gender'] as String?,
      profilePicture: json['profile_picture'] as Map?,
      photos: json['photos'] as List<dynamic>?,
      about: json['about'] as String?,
      currentlyStaying: json['currently_staying'] as String?,
      hometown: json['hometown'] as String?,
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
      'university_major': universityMajor,
      'university_year': universityYear,
      'username': username,
      "dob": dob?.toIso8601String(),
      'gender': gender,
      'interested_gender': interestedGender,
      'photos': photos,
      'profile_picture': profilePicture,
      'about': about,
      'currently_staying': currentlyStaying,
      'hometown': hometown,
      'height': height,
      'weight': weight,
      'religion': religion,
      'smoking_info': smokingInfo,
      'drinking_info': drinkingInfo,
      'looking_for': lookingFor,
    };
  }
}
