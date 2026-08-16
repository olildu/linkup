import 'package:flutter/material.dart';
import 'package:linkup/features/discovery/data/match_candidate_model.dart';
import 'package:linkup/features/profile/data/models/user_model.dart';

class UniversityInfoModel {
  final String universityMajor;
  final int universityYear;

  const UniversityInfoModel({
    required this.universityMajor,
    required this.universityYear,
  });

  factory UniversityInfoModel.fromJson(Map<String, dynamic> json) {
    return UniversityInfoModel(
      universityMajor: json['universityMajor'] ?? '',
      universityYear: json['universityYear'] ?? 0,
    );
  }

  factory UniversityInfoModel.fromMatchCandidate(
    MatchCandidateModel candidate,
  ) {
    return UniversityInfoModel(
      universityMajor: candidate.universityMajor,
      universityYear: candidate.universityYear,
    );
  }

  factory UniversityInfoModel.fromUserModel(UserModel user) {
    return UniversityInfoModel(
      universityMajor: user.universityMajor!,
      universityYear: user.universityYear!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'universityMajor': universityMajor,
      'universityYear': universityYear,
    }..removeWhere((key, data) => data == null);
  }

  Map<String, Map<String, dynamic>> asIconMap() {
    return {
      'universityMajor': {
        'icon': Icons.school_rounded,
        'value': universityMajor,
        'index': 5,
        'title': "Major",
      },
      'universityYear': {
        'icon': Icons.calendar_today_rounded,
        'value': 'Year $universityYear',
        'index': 6,
        'title': "Year",
      },
    };
  }
}
