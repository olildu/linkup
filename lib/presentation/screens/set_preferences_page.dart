import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/domain/entities/user_preference_entity.dart';
import 'package:linkup/logic/bloc/profile/own/preferences_bloc/preferences_bloc.dart';
import 'package:linkup/presentation/components/common/title_sub_builder.dart';
import 'package:linkup/presentation/components/signup_page/option_builder.dart';

class SetPreferencesPage extends StatefulWidget {
  const SetPreferencesPage({super.key});

  @override
  State<SetPreferencesPage> createState() => _SetPreferencesPageState();
}

class _SetPreferencesPageState extends State<SetPreferencesPage> {
  String? _toNullableString(String? val) => (val == "Don't mind") ? null : val;

  void _updatePreferences({
    required UserPreferenceEntity existingPreference,
    String? interestedGender,
    int? height,
    int? weight,
    String? religion,
    bool? drinkingStatus,
    bool? smokingStatus,
    String? lookingFor,
    String? currentlyStaying,
  }) {
    // Log the values of _toNullableString(religion) and existingPreference.religion
    log('_toNullableString(religion): ${_toNullableString(religion)}');
    log('existingPreference.religion: ${existingPreference.religion}');

    final updatedPreference = UserPreferenceEntity(
      interestedGender: _toNullableString(interestedGender ?? existingPreference.interestedGender),
      height: height ?? existingPreference.height,
      weight: weight ?? existingPreference.weight,
      religion: _toNullableString(religion ?? existingPreference.religion),
      drinkingStatus: drinkingStatus ?? existingPreference.drinkingStatus,
      smokingStatus: smokingStatus ?? existingPreference.smokingStatus,
      lookingFor: _toNullableString(lookingFor ?? existingPreference.lookingFor),
      currentlyStaying: _toNullableString(currentlyStaying ?? existingPreference.currentlyStaying),
    );

    context.read<PreferencesBloc>().add(PreferencesUpdateEvent(userPreference: updatedPreference));
  }

  @override
  void initState() {
    super.initState();
    context.read<PreferencesBloc>().add(PreferencesLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesBloc, PreferencesState>(
      builder: (context, state) {
        if (state is PreferencesInitial || state is PreferencesLoading) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is PreferencesLoaded) {
          UserPreferenceEntity userPreference = state.userPreference;
          return Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0,
              title: Text(
                'Set Your Preferences',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
            ),

            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BuildTitleSubtitle(title: "Interested Gender", subtitle: "Choose who you'd like to connect with on campus."),

                      Gap(20.h),

                      OptionBuilder(
                        options: ["Male", "Female"],
                        textSize: 14.sp,
                        currentOption: userPreference.interestedGender ?? "Don't mind",
                        onChanged: (obj) {
                          _updatePreferences(existingPreference: userPreference, interestedGender: obj);
                          log('interestedGender: $obj');
                        },
                      ),

                      Gap(20.h),

                      BuildTitleSubtitle(title: 'Smoking Preference', subtitle: 'Let us know your comfort level with smoking habits.'),

                      Gap(20.h),

                      OptionBuilder(
                        options: ["Open to smokers", "Prefer non-smokers", "Don't mind"],
                        textSize: 14.sp,
                        currentOption: userPreference.smokingStatus == null
                            ? "Don't mind"
                            : userPreference.smokingStatus!
                            ? "Open to smokers"
                            : "Prefer non-smokers",
                        onChanged: (obj) {
                          bool? smokingStatus;
                          if (obj == "Open to smokers") {
                            smokingStatus = true;
                          } else if (obj == "Prefer non-smokers") {
                            smokingStatus = false;
                          } else {
                            smokingStatus = null;
                          }

                          _updatePreferences(existingPreference: userPreference, smokingStatus: smokingStatus);
                          log('smokingStatus: $smokingStatus');
                        },
                      ),

                      Gap(20.h),

                      BuildTitleSubtitle(title: 'Drinking Preference', subtitle: 'Share your preference regarding social drinking.'),

                      Gap(20.h),

                      OptionBuilder(
                        options: ["Open to drinkers", "Prefer non-drinkers", "Don't mind"],
                        currentOption: userPreference.drinkingStatus == null
                            ? "Don't mind"
                            : userPreference.drinkingStatus!
                            ? "Open to drinkers"
                            : "Prefer non-drinkers",
                        textSize: 14.sp,
                        onChanged: (obj) {
                          bool? drinkingStatus;
                          if (obj == "Open to drinkers") {
                            drinkingStatus = true;
                          } else if (obj == "Prefer non-drinkers") {
                            drinkingStatus = false;
                          } else {
                            drinkingStatus = null;
                          }

                          _updatePreferences(existingPreference: userPreference, drinkingStatus: drinkingStatus);
                          log('drinkingStatus: $drinkingStatus');
                        },
                      ),

                      Gap(20.h),

                      BuildTitleSubtitle(title: 'Location of Residence', subtitle: 'Tell us where you’d prefer your match to be located.'),

                      Gap(20.h),

                      OptionBuilder(
                        options: ["Campus Hostel", "PG", "Home", "Flat", "Other", "Don't mind"],
                        currentOption: userPreference.currentlyStaying ?? "Don't mind",
                        textSize: 14.sp,
                        onChanged: (obj) {
                          _updatePreferences(existingPreference: userPreference, currentlyStaying: obj);
                          log('currentlyStaying: $obj');
                        },
                      ),

                      Gap(20.h),

                      BuildTitleSubtitle(title: 'Religion', subtitle: 'Mention any religious preferences for better compatibility.'),

                      Gap(20.h),

                      OptionBuilder(
                        options: ["Islam", "Sikhism", "Jainism", "Christianity", "Hinduism", "Buddhism", "Don't mind"],
                        currentOption: userPreference.religion ?? "Don't mind",
                        textSize: 14.sp,
                        onChanged: (obj) {
                          _updatePreferences(existingPreference: userPreference, religion: obj);

                          log('religion: $obj');
                        },
                      ),

                      Gap(20.h),

                      BuildTitleSubtitle(title: 'Looking For', subtitle: 'Let others know if you’re here for something casual or serious.'),

                      Gap(20.h),

                      OptionBuilder(
                        options: ["Casual", "Open to anything", "Serious", "Friends", "Don't mind"],
                        textSize: 14.sp,
                        currentOption: userPreference.lookingFor ?? "Don't mind",
                        onChanged: (obj) {
                          _updatePreferences(existingPreference: userPreference, lookingFor: obj);
                          log('lookingFor: $obj');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Center(
            child: Text(
              'Error loading preferences. Please try again later.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp, color: Theme.of(context).colorScheme.error),
            ),
          );
        }
      },
    );
  }
}
