import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:linkup/core/di/injection_container.dart';
import 'package:linkup/data/models/update_metadata_model.dart';
import 'package:linkup/domain/use_cases/auth/complete_profile_use_case.dart';
import 'package:linkup/logic/bloc/profile/own/profile_bloc.dart';
import 'package:linkup/logic/bloc/signup/signup_bloc.dart';

import 'package:provider/provider.dart';

class SignUpDataParser {
  static late UpdateMetadataModel _data;
  static late UpdateMetadataModel _latestData;

  static late SignupBloc _signupBloc;

  static final String debugTag = "SignUpDataParser";

  static void initialize(BuildContext context) {
    final state = context.read<ProfileBloc>().state;
    _signupBloc = context.read<SignupBloc>();

    if (state is ProfileLoaded) {
      _data = UpdateMetadataModel.fromUserEntity(state.user);
      _latestData = UpdateMetadataModel.fromUserEntity(state.user);
      log("SignUpDataParser initialized", name: debugTag);
    } else {
      throw Exception("ProfileBloc or SignupBloc is not loaded");
    }
  }

  static void updateField({
    String? universityMajor,
    int? universityYear,
    String? username,
    String? gender,
    String? interestedGender,
    DateTime? dob,
    List<dynamic>? photos,
    Map? profilePicture,
    String? about,
    String? currentlyStaying,
    String? hometown,
    int? height,
    int? weight,
    String? religion,
    String? smokingInfo,
    String? drinkingInfo,
    bool? drinkingStatus,
    bool? smokingStatus,
    String? lookingFor,
  }) {
    _data = UpdateMetadataModel(
      universityMajor: universityMajor ?? _data.universityMajor,
      universityYear: universityYear ?? _data.universityYear,
      username: username ?? _data.username,
      gender: gender ?? _data.gender,
      photos: photos ?? _data.photos,
      interestedGender: interestedGender ?? _data.interestedGender,
      dob: dob ?? _data.dob,
      profilePicture: profilePicture ?? _data.profilePicture,
      about: about ?? _data.about,
      currentlyStaying: currentlyStaying ?? _data.currentlyStaying,
      hometown: hometown ?? _data.hometown,
      height: height ?? _data.height,
      weight: weight ?? _data.weight,
      religion: religion ?? _data.religion,
      smokingInfo: smokingInfo ?? _data.smokingInfo,
      drinkingInfo: drinkingInfo ?? _data.drinkingInfo,
      lookingFor: lookingFor ?? _data.lookingFor,
    );

    _signupBloc.add(SignupOptionalFilled());
  }

  static Future<void> submitRegistration() async {
    log(_data.toJson().toString());
    await sl<CompleteProfileUseCase>()(_data);
  }

  static void updateData(BuildContext context, {bool fromProfilePage = false}) {
    final current = _data.toJson();
    final original = _latestData.toJson();

    final changedFields = <String, dynamic>{};

    for (final key in current.keys) {
      if (current[key] != original[key]) {
        changedFields[key] = current[key];
      }
    }

    if (changedFields.isEmpty) {
      log("No changes detected", name: debugTag);
    } else {
      log("Changed fields model: $changedFields", name: debugTag);
      context.read<ProfileBloc>().add(ProfileUpdateEvent(userUpdatedModel: _data));
    }
  }

  static UpdateMetadataModel get data => _data;
}
