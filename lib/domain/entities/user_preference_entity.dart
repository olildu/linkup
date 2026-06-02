class UserPreferenceEntity {
  final String? interestedGender;
  final int? height;
  final int? weight;
  final String? religion;
  final bool? drinkingStatus;
  final bool? smokingStatus;
  final String? lookingFor;
  final String? currentlyStaying;

  const UserPreferenceEntity({
    this.interestedGender,
    this.height,
    this.weight,
    this.religion,
    this.drinkingStatus,
    this.smokingStatus,
    this.lookingFor,
    this.currentlyStaying,
  });
}
