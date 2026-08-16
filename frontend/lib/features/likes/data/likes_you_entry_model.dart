import 'package:linkup/features/discovery/data/match_candidate_model.dart';

class LikesYouEntryModel {
  final int id;
  final bool revealed;
  final MatchCandidateModel? profile;
  final Map? firstPhoto;

  LikesYouEntryModel({
    required this.id,
    required this.revealed,
    this.profile,
    this.firstPhoto,
  });

  factory LikesYouEntryModel.fromJson(Map<String, dynamic> json) {
    return LikesYouEntryModel(
      id: json['id'] as int,
      revealed: json['revealed'] as bool,
      profile: json['profile'] != null
          ? MatchCandidateModel.fromJson(json['profile'])
          : null,
      firstPhoto: json['first_photo'] as Map?,
    );
  }
}
