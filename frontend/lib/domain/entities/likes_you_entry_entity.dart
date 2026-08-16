import 'package:linkup/domain/entities/match_candidate_entity.dart';

class LikesYouEntryEntity {
  final int id;
  final bool revealed;
  final MatchCandidateEntity? profile;
  final Map? firstPhoto;

  const LikesYouEntryEntity({
    required this.id,
    required this.revealed,
    this.profile,
    this.firstPhoto,
  });
}
