import 'package:flutter/material.dart';
import 'package:linkup/data/models/match_candidate_model.dart';
import 'package:linkup/data/models/user_model.dart';
import 'package:linkup/domain/entities/match_candidate_entity.dart';
import 'package:linkup/domain/entities/user_entity.dart';

class CandidateInfoModel {
  final int? id;
  final int? height;
  final int? weight;
  final String? religion;
  final String? smokingInfo;
  final String? drinkingInfo;
  final String? lookingFor;
  final String? gender;
  final String? currentlyStaying;
  final String? hometown;

  const CandidateInfoModel({
    this.id,
    this.height,
    this.weight,
    this.religion,
    this.smokingInfo,
    this.drinkingInfo,
    this.lookingFor,
    this.gender,
    this.currentlyStaying,
    this.hometown,
  });

  factory CandidateInfoModel.fromJson(Map<String, dynamic> json) {
    return CandidateInfoModel(
      id: json['id'] as int?,
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      religion: json['religion'] as String?,
      smokingInfo: json['smoking_info'] as String?,
      drinkingInfo: json['drinking_info'] as String?,
      lookingFor: json['looking_for'] as String?,
      gender: json['gender'] as String?,
      currentlyStaying: json['currently_staying'] as String?,
      hometown: json['hometown'] as String?,
    );
  }

  factory CandidateInfoModel.fromMatchCandidate(MatchCandidateModel candidate) {
    return CandidateInfoModel(
      id: candidate.id,
      height: candidate.height,
      weight: candidate.weight,
      religion: candidate.religion,
      smokingInfo: candidate.smokingInfo,
      drinkingInfo: candidate.drinkingInfo,
      lookingFor: candidate.lookingFor,
      gender: candidate.gender,
      currentlyStaying: candidate.currentlyStaying,
      hometown: candidate.hometown,
    );
  }

  factory CandidateInfoModel.fromUserModel(UserModel user) {
    return CandidateInfoModel(
      height: user.height,
      weight: user.weight,
      religion: user.religion,
      smokingInfo: user.smokingInfo,
      drinkingInfo: user.drinkingInfo,
      lookingFor: user.lookingFor,
      gender: user.gender,
      currentlyStaying: user.currentlyStaying,
      hometown: user.hometown,
    );
  }

  factory CandidateInfoModel.fromUserEntity(UserEntity user) {
    return CandidateInfoModel(
      height: user.height,
      weight: user.weight,
      religion: user.religion,
      smokingInfo: user.smokingInfo,
      drinkingInfo: user.drinkingInfo,
      lookingFor: user.lookingFor,
      gender: user.gender,
      currentlyStaying: user.currentlyStaying,
      hometown: user.hometown,
    );
  }

  factory CandidateInfoModel.fromMatchCandidateEntity(
    MatchCandidateEntity candidate,
  ) {
    return CandidateInfoModel(
      id: candidate.id,
      height: candidate.height,
      weight: candidate.weight,
      religion: candidate.religion,
      smokingInfo: candidate.smokingInfo,
      drinkingInfo: candidate.drinkingInfo,
      lookingFor: candidate.lookingFor,
      gender: candidate.gender,
      currentlyStaying: candidate.currentlyStaying,
      hometown: candidate.hometown,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'religion': religion,
      'smoking_info': smokingInfo,
      'drinking_info': drinkingInfo,
      'looking_for': lookingFor,
      'gender': gender,
      'currently_staying': currentlyStaying,
      'hometown': hometown,
    };
    // }..removeWhere((key, value) => value == null);
  }

  Map<String, Map<String, dynamic>> asIconMap({
    bool showGender = true,
    bool showLocationInfo = true,
  }) {
    final map = <String, Map<String, dynamic>>{};

    if (showGender) {
      map['gender'] = {
        'icon': gender == "Male" ? Icons.man_rounded : Icons.woman_rounded,
        'value': gender,
        'index': -1,
        'title': "Gender",
      };
    }

    if (showLocationInfo) {
      map.addAll({
        'currently_staying': {
          'icon': Icons.location_city_rounded,
          'value': currentlyStaying,
          'index': -1,
          'title': "Currently Staying",
        },
        'hometown': {
          'icon': Icons.home_rounded,
          'value': hometown,
          'index': 0,
          'title': "Hometown",
        },
      });
    }

    map.addAll({
      'height': {
        'icon': Icons.straighten_rounded,
        'value': height != null ? '$height cm' : null,
        'index': 1,
        'title': "Height",
      },
      'weight': {
        'icon': Icons.monitor_weight,
        'value': weight != null ? '$weight kg' : null,
        'index': 2,
        'title': "Weight",
      },
      'religion': {
        'icon': Icons.church_rounded,
        'value': religion,
        'index': 3,
        'title': "Religion",
      },
      'smoking': {
        'icon': Icons.smoking_rooms_rounded,
        'value': smokingInfo,
        'index': 4,
        'title': "Smoking",
      },
      'drinking': {
        'icon': Icons.local_bar_rounded,
        'value': drinkingInfo,
        'index': 5,
        'title': "Drinking",
      },
      'looking_for': {
        'icon': Icons.favorite_outline_rounded,
        'value': lookingFor,
        'index': 6,
        'title': "Looking For",
      },
    });

    // map.removeWhere((key, item) => item['value'] == null);
    return map;
  }
}
