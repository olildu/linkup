// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, must_be_immutable, library_private_types_in_public_api

import 'package:linkup/api/api_calls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Map userDataTags = {
  "uid": UserValues.uid,
  'type': 'uploadTagData',
  'key': UserValues.cookieValue,
};

class ProgressTracker extends StatelessWidget {
  final double value;

  const ProgressTracker({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: value),
        duration: Duration(milliseconds: 500), // Adjust the duration as needed
        builder: (context, double width, child) {
          return Row(
            children: [
              Container(
                width: width,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HeightContainer extends StatefulWidget {
  String heightValue; // String message field to hold the passed string

  HeightContainer(
      {super.key,
      required this.heightValue}); // Constructor to initialize the message field

  @override
  _HeightContainerState createState() => _HeightContainerState();
}

class _HeightContainerState extends State<HeightContainer> {
  @override
  Widget build(BuildContext context) {
    // Get the current users height and convert to int by replacing cm and " " (space values) and then substract by 150 => gets the index
    int heightIndex =
        (int.tryParse(widget.heightValue.replaceAll("cm", "").trim()) ?? 0) -
            150;
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(height: 50),
          Column(
            children: [
              Transform.rotate(
                angle: -0.8,
                child: Icon(Icons.straighten_rounded, size: 50),
              ),
              SizedBox(height: 20),
              Text(
                "What is your height?",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 80),
              GestureDetector(
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => SizedBox(
                      height: 250,
                      child: Container(
                        decoration: BoxDecoration(),
                        child: CupertinoPicker(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                              initialItem: heightIndex),
                          children: List.generate(
                            71,
                            (index) {
                              final height = 150 + index;
                              return Text(
                                "$height cm",
                                style: GoogleFonts.poppins(),
                              );
                            },
                          ),
                          onSelectedItemChanged: (value) {
                            setState(() {
                              widget.heightValue = "${value + 150} cm";
                            });
                            userDataTags["keyToUpdate"] = "height";
                            userDataTags["value"] = "${value + 150} cm";
                            // You can use userDataTags here if it's declared in the parent widget or accessible in this scope.
                          },
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color.fromARGB(255, 233, 233, 233),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.heightValue,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Skip",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class DrinkingContainer extends StatelessWidget {
  final Function()? onOptionSelected;

  const DrinkingContainer({super.key, this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(height: 50),
          Column(
            children: [
              Icon(Icons.wine_bar_rounded, size: 50),
              SizedBox(height: 20),
              Text(
                "Do you drink?",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500, fontSize: 20),
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OptionChildrenBuilder("Frequently", "drinkingStatus",
                              context, onOptionSelected),
                          SizedBox(height: 10),
                          OptionChildrenBuilder("Socially", "drinkingStatus",
                              context, onOptionSelected),
                          SizedBox(height: 10),
                          OptionChildrenBuilder("Rarely", "drinkingStatus",
                              context, onOptionSelected),
                          SizedBox(height: 10),
                          OptionChildrenBuilder("Never", "drinkingStatus",
                              context, onOptionSelected),
                          SizedBox(height: 10),
                          OptionChildrenBuilder("Sober", "drinkingStatus",
                              context, onOptionSelected),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                "Skip",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              )
            ],
          )
        ],
      ),
    );
  }
}

class SmokingContainer extends StatelessWidget {
  final Function()? onOptionSelected;

  const SmokingContainer({super.key, this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(height: 50),
          Column(
            children: [
              Icon(Icons.smoking_rooms_rounded, size: 50),
              SizedBox(height: 20),
              Text(
                "Do you smoke?",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500, fontSize: 20),
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OptionChildrenBuilder("Socially", "smokingStatus",
                              context, onOptionSelected),
                          SizedBox(height: 10),
                          OptionChildrenBuilder("Regularly", "smokingStatus",
                              context, onOptionSelected),
                          SizedBox(height: 10),
                          OptionChildrenBuilder("Never", "smokingStatus",
                              context, onOptionSelected),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                "Skip",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              )
            ],
          )
        ],
      ),
    );
  }
}

class LookingForContainer extends StatelessWidget {
  final Function()? onOptionSelected;

  const LookingForContainer({super.key, this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(height: 50),
          Column(
            children: [
              Icon(Icons.search_rounded, size: 50),
              SizedBox(height: 20),
              Text(
                "What do you want from your dates?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OptionChildrenBuilder("Relationship", "lookingFor",
                              context, onOptionSelected),
                          SizedBox(height: 10),
                          OptionChildrenBuilder("Something Casual",
                              "lookingFor", context, onOptionSelected),
                          SizedBox(height: 10),
                          OptionChildrenBuilder("Don't know yet", "lookingFor",
                              context, onOptionSelected),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                "Skip",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              )
            ],
          )
        ],
      ),
    );
  }
}

class ReligionContainer extends StatelessWidget {
  final Function()? onOptionSelected;

  const ReligionContainer({super.key, this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            SizedBox(height: 50),
            Column(
              children: [
                Icon(Icons.synagogue_rounded, size: 50),
                SizedBox(height: 20),
                Text(
                  "Do you identify with a religion?",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500, fontSize: 20),
                ),
                SizedBox(height: 40),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: ListView(
                    children: [
                      OptionChildrenBuilder("Agnostic", "religionStatus",
                          context, onOptionSelected),
                      SizedBox(height: 10),
                      OptionChildrenBuilder("Atheist", "religionStatus",
                          context, onOptionSelected),
                      SizedBox(height: 10),
                      OptionChildrenBuilder("Buddhist", "religionStatus",
                          context, onOptionSelected),
                      SizedBox(height: 10),
                      OptionChildrenBuilder("Catholic", "religionStatus",
                          context, onOptionSelected),
                      SizedBox(height: 10),
                      OptionChildrenBuilder("Christian", "religionStatus",
                          context, onOptionSelected),
                      SizedBox(height: 10),
                      OptionChildrenBuilder(
                          "Hindu", "religionStatus", context, onOptionSelected),
                      SizedBox(height: 10),
                      OptionChildrenBuilder(
                          "Jain", "religionStatus", context, onOptionSelected),
                      SizedBox(height: 10),
                      OptionChildrenBuilder("Jewish", "religionStatus", context,
                          onOptionSelected),
                      SizedBox(height: 10),
                      OptionChildrenBuilder("Mormon", "religionStatus", context,
                          onOptionSelected),
                      SizedBox(height: 10),
                      OptionChildrenBuilder("Muslim", "religionStatus", context,
                          onOptionSelected),
                      SizedBox(height: 10),
                      OptionChildrenBuilder(
                          "Sikh", "religionStatus", context, onOptionSelected),
                      SizedBox(height: 10),
                      OptionChildrenBuilder(
                          "Other", "religionStatus", context, onOptionSelected),
                      SizedBox(height: 30),
                      Center(
                          child: Text("Skip",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

void _updateUserData(String Type, String optionText) async {
  userDataTags["keyToUpdate"] = Type;
  userDataTags["value"] = optionText;

  await ApiCalls.storeUserMetaData(userDataTags);
}

Widget OptionChildrenBuilder(
    String optionText, String Type, BuildContext context,
    [Function()? onOptionSelected]) {
  return GestureDetector(
    onTap: () async {
      _updateUserData(Type, optionText);
      if (onOptionSelected != null) {
        onOptionSelected();
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Center(
        child: Text(
          optionText,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ),
  );
}
