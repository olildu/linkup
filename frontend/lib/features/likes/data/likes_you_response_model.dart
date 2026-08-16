import 'package:linkup/features/likes/data/likes_you_entry_model.dart';

class LikesYouResponseModel {
  final List<LikesYouEntryModel> entries;
  final int totalCount;
  final int unseenCount;

  LikesYouResponseModel({
    required this.entries,
    required this.totalCount,
    required this.unseenCount,
  });

  factory LikesYouResponseModel.fromJson(Map<String, dynamic> json) {
    return LikesYouResponseModel(
      entries: (json['entries'] as List)
          .map((j) => LikesYouEntryModel.fromJson(j))
          .toList(),
      totalCount: json['total_count'] as int,
      unseenCount: json['unseen_count'] as int,
    );
  }
}
