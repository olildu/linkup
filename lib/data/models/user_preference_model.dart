class UserPreferenceModel {
  final String? interestedGender;
  final int? height;
  final int? weight;
  final String? religion;
  final bool? drinkingStatus;
  final bool? smokingStatus;
  final String? lookingFor;
  final String? currentlyStaying;

  UserPreferenceModel({
    this.interestedGender,
    this.height,
    this.weight,
    this.religion,
    this.drinkingStatus,
    this.smokingStatus,
    this.lookingFor,
    this.currentlyStaying,
  });

  factory UserPreferenceModel.fromJson(Map<String, dynamic> json) {
    return UserPreferenceModel(
      interestedGender: json['interested_gender'] as String?,
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      religion: json['religion'] as String?,
      drinkingStatus: json['drinking_status'] as bool?,
      smokingStatus: json['smoking_status'] as bool?,
      lookingFor: json['looking_for'] as String?,
      currentlyStaying: json['currently_staying'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interested_gender': interestedGender,
      'height': height,
      'weight': weight,
      'religion': religion,
      'drinking_status': drinkingStatus,
      'smoking_status': smokingStatus,
      'looking_for': lookingFor,
      'currently_staying': currentlyStaying,
    };
  }
}
