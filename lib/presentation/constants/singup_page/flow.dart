import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/logic/cubit/theme/theme_cubit.dart';
import 'package:linkup/presentation/components/common/bullet_point_builder.dart';
import 'package:linkup/presentation/components/common/image_picker_builder.dart';
import 'package:linkup/presentation/components/signup_page/city_lookup.dart';
import 'package:linkup/presentation/components/signup_page/image_builder.dart';
import 'package:linkup/presentation/components/signup_page/lookup_picker.dart';
import 'package:linkup/presentation/components/signup_page/option_builder.dart';
import 'package:linkup/presentation/components/signup_page/picker_builder_component.dart';
import 'package:linkup/presentation/constants/singup_page/date_picker.dart';
import 'package:linkup/presentation/components/signup_page/page_title_builder_component.dart';
import 'package:linkup/presentation/components/signup_page/text_input_builder_component.dart';
import 'package:linkup/logic/provider/data_validator_provider.dart';
import 'package:linkup/data/data_parser/signup_page/data_parser.dart';
import 'package:linkup/data/models/signup_options_model.dart';
import 'package:provider/provider.dart';

class SignUpPageFlow {
  final BuildContext context;
  final SignupOptionsConfig signupOptions;
  late final List<Map<String, dynamic>> flow;
  final Map<String, dynamic>? initialData;
  SignupProgramOption? _selectedProgram;

  SignUpPageFlow(this.context, {required this.signupOptions, this.initialData}) {
    _selectedProgram =
        signupOptions.programForValue(initialData?['university_major']) ??
        signupOptions.defaultProgram;
    initialData == null ? _initializeSignUpFlow() : _initializeUpdateFlow();
    SignUpDataParser.initialize(context);
  }

  DataValidatorProvider get dataValidatorProvider =>
      Provider.of<DataValidatorProvider>(context, listen: false);
  ThemeCubit get themeCubit => context.read<ThemeCubit>();

  List<String> get _majorLabels => signupOptions.programLabels;

  List<String> _yearLabels() => signupOptions.yearLabelsForProgram(_selectedProgram);

  Widget _buildMajorPicker() {
    return LookupPicker(
      items: _majorLabels,
      label: 'Major',
      placeHolder: 'Search your major',
      onChanged: (val) {
        Future.delayed(const Duration(milliseconds: 200), () {
          final selectedProgram =
              signupOptions.programForValue(val) ?? signupOptions.defaultProgram;
          _selectedProgram = selectedProgram;
          dataValidatorProvider.allowDisallow(true);
          SignUpDataParser.updateField(universityMajor: selectedProgram.label);
        });
      },
    );
  }

  Widget _buildYearPicker() {
    return BuildPicker(
      controller: FixedExtentScrollController(initialItem: 0),
      items: _yearLabels(),
      selectedIndex: _selectedYearIndex(),
      onSelectedItemChanged: (index) {
        Future.delayed(const Duration(milliseconds: 500), () {
          dataValidatorProvider.allowDisallow(true);
          SignUpDataParser.updateField(universityYear: index + 1);
        });
      },
      dividerGap: 0.15,
    );
  }

  Widget buildAction(int index) {
    if (index == 4) {
      return _buildMajorPicker();
    }

    if (index == 5) {
      return _buildYearPicker();
    }

    return flow[index]['action'] as Widget;
  }

  int _selectedYearIndex() {
    final currentYear = initialData?['university_year'];
    if (currentYear is int && currentYear > 0) {
      final maxIndex = _yearLabels().length - 1;
      return currentYear - 1 > maxIndex ? maxIndex : currentYear - 1;
    }

    return 0;
  }

  void _initializeSignUpFlow() {
    flow = [
      {
        'title': PageTitle(
          inputText: "Tell us who you are, So we know whom to link you up with later",
          highlightWord: "who",
          subText: "linkup keeps your personal information safe and private",
        ),
        'action': ImageBuilder(
          imageMetaData: "assets/images/care.png",
          darkMode: themeCubit.isDark,
        ),
        "showProgressBar": false,
      },
      {
        'title': PageTitle(inputText: "Your name so others know you!", highlightWord: "name"),
        'action': TextInput(
          label: "Name",
          placeHolder: "Enter your name",
          initialValue: 'Balls Mon',
          onChanged: (val) {
            if (val.trim().isNotEmpty) {
              dataValidatorProvider.allowDisallow(true);
              SignUpDataParser.updateField(username: val.trim());
            } else {
              dataValidatorProvider.allowDisallow(false);
            }
          },
        ),
        'index': 0,
      },
      {
        'title': PageTitle(
          inputText: "When's your birthday? We'll celebrate with you!",
          highlightWord: "birthday",
        ),
        'action': DatePicker(
          onChanged: (val) {
            Future.delayed(const Duration(milliseconds: 500), () {
              dataValidatorProvider.allowDisallow(true);
              SignUpDataParser.updateField(dob: val);
            });
          },
        ),
        'index': 1,
      },
      {
        'title': PageTitle(
          inputText: "Select your gender to help others get to know you better",
          highlightWord: "gender",
        ),
        'action': OptionBuilder(
          options: ["Male", "Female"],
          onChanged: (val) {
            dataValidatorProvider.allowDisallow(true);
            SignUpDataParser.updateField(gender: val);
          },
        ),
        'index': 2,
      },
      {
        'title': PageTitle(
          inputText: "Let us know who you're interested in connecting with",
          highlightWord: "interested",
        ),
        'action': OptionBuilder(
          options: ["Male", "Female"],
          onChanged: (val) {
            dataValidatorProvider.allowDisallow(true);
            SignUpDataParser.updateField(interestedGender: val);
          },
        ),
        'index': 3,
      },
      {
        'title': PageTitle(
          inputText: "What's your major? Let's connect you with others in the field!",
          highlightWord: "major",
        ),
        'index': 4,
      },
      {
        'title': PageTitle(
          inputText: "What year are you in? We'll match you with others in your journey",
          highlightWord: "year",
        ),
        'index': 5,
      },
      {
        'title': PageTitle(
          inputText: "Where are you currently staying?",
          highlightWord: "currently",
        ),
        'action': OptionBuilder(
          options: ["Campus Hostel", "PG", "Home", "Flat", "Other"],
          onChanged: (val) {
            dataValidatorProvider.allowDisallow(true);
            SignUpDataParser.updateField(currentlyStaying: val);
          },
          currentOption: initialData?["currently_staying"],
        ),
        'index': 6,
      },
      {
        'title': PageTitle(
          inputText: "Where is your hometown? Let us know where you’re from!",
          highlightWord: "hometown",
        ),
        'action': CityLookup(
          onChanged: (val) {
            dataValidatorProvider.allowDisallow(true);
            SignUpDataParser.updateField(hometown: val);
          },
        ),
        'index': 7,
      },
      {
        'title': PageTitle(
          inputText: "Add at least 2 photos so others can see you and put face to name",
          highlightWord: "photos",
        ),
        'action': SingleChildScrollView(
          child: Column(
            children: [
              ImagePickerBuilder(
                onImagesChanged: (p0, _) {
                  if (p0.isNotEmpty && p0.length >= 2) {
                    dataValidatorProvider.allowDisallow(true);
                    SignUpDataParser.updateField(photos: p0);
                  } else {
                    dataValidatorProvider.allowDisallow(false);
                  }
                },
                maxImages: 6,
                allowMultipleSelection: true,
              ),
              Gap(10.h),
              BulletPointBuilder(
                items: [
                  "Upload photos where your face is clearly visible",
                  "Photos that don't resemble you will be removed and flagged",
                ],
              ),
            ],
          ),
        ),
        'index': 8,
      },
      {
        'title': PageTitle(
          inputText: "Tell us about yourself. We'd love to know you!",
          highlightWord: "about",
        ),
        'action': TextInput(
          label: "About",
          placeHolder: "Tell us about yourself",
          onChanged: (val) {
            if (val.isNotEmpty) {
              dataValidatorProvider.allowDisallow(true);
              SignUpDataParser.updateField(about: val);
            } else {
              dataValidatorProvider.allowDisallow(false);
            }
          },
        ),
        'index': 9,
      },

      {
        'title': PageTitle(
          inputText: "One last step\nTell us what you love, So we can match you better",
          highlightWord: ["love", "match"],
        ),
        'action': ImageBuilder(
          imageMetaData: "assets/images/like.png",
          darkMode: themeCubit.isDark,
        ),
        'showProgressBar': false,
      },
      {
        'title': PageTitle(
          inputText: "How tall are you? Some people are into stats!",
          highlightWord: "tall",
        ),
        'action': BuildPicker(
          controller: FixedExtentScrollController(initialItem: 0),
          items: List.generate(100, (index) => "${110 + index + 1} cm"),
          onSelectedItemChanged: (index) {
            Future.delayed(const Duration(milliseconds: 500), () {
              dataValidatorProvider.allowDisallow(true);
              SignUpDataParser.updateField(height: 110 + index + 1);
            });
          },
          selectedIndex: initialData?["height"] != null ? (initialData!["height"] - 111) : null,
          dividerGap: 0.15,
        ),
        'showProgressBar': false,
      },
      {
        'title': PageTitle(
          inputText: "What's your weight? Totally up to you if you want to share.",
          highlightWord: "weight",
        ),
        'action': BuildPicker(
          controller: FixedExtentScrollController(initialItem: 0),
          items: List.generate(90, (index) => "${30 + index + 1} kg"),
          onSelectedItemChanged: (index) {
            Future.delayed(const Duration(milliseconds: 500), () {
              dataValidatorProvider.allowDisallow(true);
              SignUpDataParser.updateField(weight: 30 + index + 1);
            });
          },
          dividerGap: 0.15,
          selectedIndex: initialData?["weight"] != null ? (initialData!["weight"] - 31) : null,
        ),
        'showProgressBar': false,
      },
      {
        'title': PageTitle(
          inputText: "What's your religion? Only if you feel like sharing!",
          highlightWord: "religion",
        ),
        'action': OptionBuilder(
          options: [
            "Islam",
            "Sikhism",
            "Jainism",
            "Christianity",
            "Hinduism",
            "Buddhism",
            "Others",
          ],
          onChanged: (val) {
            dataValidatorProvider.allowDisallow(true);
            SignUpDataParser.updateField(religion: val);
          },
          currentOption: initialData?['religion'],
        ),
        'showProgressBar': false,
      },
      {
        'title': PageTitle(
          inputText: "Do you smoke? Just helping people vibe better",
          highlightWord: "smoke",
        ),
        'action': OptionBuilder(
          options: ["Yes", "Trying to quit", "Occasionally", "No"],
          onChanged: (val) {
            dataValidatorProvider.allowDisallow(true);
            SignUpDataParser.updateField(smokingInfo: val);
          },
          currentOption: initialData?["smoking_info"],
        ),
        'showProgressBar': false,
      },
      {
        'title': PageTitle(
          inputText: "Do you enjoy a drink now and then or not your thing?",
          highlightWord: "drink",
        ),
        'action': OptionBuilder(
          options: ["Yes", "Trying to quit", "Occasionally", "No"],
          onChanged: (val) {
            dataValidatorProvider.allowDisallow(true);
            SignUpDataParser.updateField(drinkingInfo: val);
          },
          currentOption: initialData?["drinking_info"],
        ),
        'showProgressBar': false,
      },
      {
        'title': PageTitle(
          inputText: "What kind of connection are you looking for?",
          highlightWord: "connection",
        ),
        'action': OptionBuilder(
          options: ["Casual", "Open to anything", "Serious", "Friends", "Not sure yet"],
          onChanged: (val) {
            dataValidatorProvider.allowDisallow(true);
            SignUpDataParser.updateField(lookingFor: val);
          },
          currentOption: initialData?["looking_for"],
        ),
        'showProgressBar': false,
      },
    ];
  }

  void _initializeUpdateFlow() {
    flow = [
      {
        'title': PageTitle(
          inputText: "Where are you currently staying?",
          highlightWord: "currently",
        ),
        'action': OptionBuilder(
          options: ["Campus Hostel", "PG", "Home", "Flat", "Other"],
          onChanged: (val) {
            dataValidatorProvider.allowDisallow(true);
            SignUpDataParser.updateField(currentlyStaying: val);
          },
          currentOption: initialData?["currently_staying"],
        ),
        'showProgressBar': false,
      },
      {
        'title': PageTitle(
          inputText: "Where is your hometown? Let us know where you’re from!",
          highlightWord: "hometown",
        ),
        'action': CityLookup(
          onChanged: (val) {
            dataValidatorProvider.allowDisallow(true);
            SignUpDataParser.updateField(hometown: val);
          },
        ),
        'showProgressBar': false,
      },
      {
        'title': PageTitle(
          inputText: "How tall are you? Some people are into stats!",
          highlightWord: "tall",
        ),
        'action': BuildPicker(
          controller: FixedExtentScrollController(initialItem: 0),
          items: List.generate(100, (index) => "${110 + index + 1} cm"),
          onSelectedItemChanged: (index) {
            Future.delayed(const Duration(milliseconds: 500), () {
              dataValidatorProvider.allowDisallow(true);
              SignUpDataParser.updateField(height: 110 + index + 1);
            });
          },
          selectedIndex: initialData?["height"] != null ? (initialData!["height"] - 111) : null,
          dividerGap: 0.15,
        ),
        'showProgressBar': false,
      },
      {
        'title': PageTitle(
          inputText: "What's your weight? Totally up to you if you want to share.",
          highlightWord: "weight",
        ),
        'action': BuildPicker(
          controller: FixedExtentScrollController(initialItem: 0),
          items: List.generate(90, (index) => "${30 + index + 1} kg"),
          onSelectedItemChanged: (index) {
            Future.delayed(const Duration(milliseconds: 500), () {
              dataValidatorProvider.allowDisallow(true);
              SignUpDataParser.updateField(weight: 30 + index + 1);
            });
          },
          dividerGap: 0.15,
          selectedIndex: initialData?["weight"] != null ? (initialData!["weight"] - 31) : null,
        ),
        'showProgressBar': false,
      },
      {
        'title': PageTitle(
          inputText: "What's your religion? Only if you feel like sharing!",
          highlightWord: "religion",
        ),
        'action': OptionBuilder(
          options: [
            "Islam",
            "Sikhism",
            "Jainism",
            "Christianity",
            "Hinduism",
            "Buddhism",
            "Others",
          ],
          onChanged: (val) {
            dataValidatorProvider.allowDisallow(true);
            SignUpDataParser.updateField(religion: val);
          },
          currentOption: initialData?['religion'],
        ),
        'showProgressBar': false,
      },
      {
        'title': PageTitle(
          inputText: "Do you smoke? Just helping people vibe better",
          highlightWord: "smoke",
        ),
        'action': OptionBuilder(
          options: ["Yes", "Trying to quit", "Occasionally", "No"],
          onChanged: (val) {
            dataValidatorProvider.allowDisallow(true);
            SignUpDataParser.updateField(smokingInfo: val);
          },
          currentOption: initialData?["smoking_info"],
        ),
        'showProgressBar': false,
      },
      {
        'title': PageTitle(
          inputText: "Do you enjoy a drink now and then or not your thing?",
          highlightWord: "drink",
        ),
        'action': OptionBuilder(
          options: ["Yes", "Trying to quit", "Occasionally", "No"],
          onChanged: (val) {
            dataValidatorProvider.allowDisallow(true);
            SignUpDataParser.updateField(drinkingInfo: val);
          },
          currentOption: initialData?["drinking_info"],
        ),
        'showProgressBar': false,
      },
      {
        'title': PageTitle(
          inputText: "What kind of connection are you looking for?",
          highlightWord: "connection",
        ),
        'action': OptionBuilder(
          options: ["Casual", "Open to anything", "Serious", "Friends", "Not sure yet"],
          onChanged: (val) {
            dataValidatorProvider.allowDisallow(true);
            SignUpDataParser.updateField(lookingFor: val);
          },
          currentOption: initialData?["looking_for"],
        ),
        'showProgressBar': false,
      },
    ];
  }
}
