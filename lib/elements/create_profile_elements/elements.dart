
// ignore_for_file: non_constant_identifier_names

import 'package:demo/elements/profile_elements/elements.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LookingForContainer extends StatelessWidget {
  final Function()? onOptionSelected;

  const LookingForContainer({Key? key, this.onOptionSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                titleAndSubtitle("What do you want from dates?", "Let's get to know you better", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),

                const SizedBox(height: 50,),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OptionChildrenBuilder("Relationship", "LookingFor", onOptionSelected),
                            const SizedBox(height: 10,),
                            OptionChildrenBuilder("Something Casual", "LookingFor", onOptionSelected),
                            const SizedBox(height: 10,),
                            OptionChildrenBuilder("Don't know yet", "LookingFor", onOptionSelected),
                            const SizedBox(height: 10,),
                            OptionChildrenBuilder("Skip", "LookingFor", onOptionSelected),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30,),
                Text("Skip", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),)
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ReligionContainer extends StatelessWidget {
  final Function()? onOptionSelected;

  const ReligionContainer({Key? key, this.onOptionSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                const SizedBox(height: 20,),
                titleAndSubtitle("Do you identify with a religion?", "Let's get to know you better", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),

                const SizedBox(height: 50,),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.6, // Adjust the height as needed
                    child: ListView(
                      children: [
                        OptionChildrenBuilder("Agnostic", "Religion", onOptionSelected),
                        const SizedBox(height: 10,),
                        OptionChildrenBuilder("Atheist", "Religion", onOptionSelected),
                        const SizedBox(height: 10,),
                        OptionChildrenBuilder("Buddhist", "Religion", onOptionSelected),
                        const SizedBox(height: 10,),
                        OptionChildrenBuilder("Catholic", "Religion", onOptionSelected),
                        const SizedBox(height: 10,),
                        OptionChildrenBuilder("Christian", "Religion", onOptionSelected),
                        const SizedBox(height: 10,),
                        OptionChildrenBuilder("Hindu", "Religion", onOptionSelected),
                        const SizedBox(height: 10,),
                        OptionChildrenBuilder("Jain", "Religion", onOptionSelected),
                        const SizedBox(height: 10,),
                        OptionChildrenBuilder("Jewish", "Religion", onOptionSelected),
                        const SizedBox(height: 10,),
                        OptionChildrenBuilder("Mormon", "Religion", onOptionSelected),
                        const SizedBox(height: 10,),
                        OptionChildrenBuilder("Muslim", "Religion", onOptionSelected),
                        const SizedBox(height: 10,),
                        OptionChildrenBuilder("Sikh", "Religion", onOptionSelected),
                        const SizedBox(height: 10,),
                        OptionChildrenBuilder("Other", "Religion", onOptionSelected),
                        const SizedBox(height: 10,),
                        OptionChildrenBuilder("Skip", "Religion", onOptionSelected),
                      ],
                    ),
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SmokingContainer extends StatelessWidget {
  final Function()? onOptionSelected;

  const SmokingContainer({Key? key, this.onOptionSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                titleAndSubtitle("Do you smoke?", "Let's get to know you better", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),
                const SizedBox(height: 50,),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OptionChildrenBuilder("Socially", "Smoking", onOptionSelected),
                            const SizedBox(height: 10,),
                            OptionChildrenBuilder("Regularly", "Smoking", onOptionSelected),
                            const SizedBox(height: 10,),
                            OptionChildrenBuilder("Never", "Smoking", onOptionSelected),
                            const SizedBox(height: 10,),
                            OptionChildrenBuilder("Skip", "Smoking", onOptionSelected),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30,),
                Text("Skip", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),)
              ],
            ),
          )
        ],
      ),
    );
  }
}

class GenderContainer extends StatelessWidget {
  final Function()? onOptionSelected;

  const GenderContainer({Key? key, this.onOptionSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                titleAndSubtitle("What do you identify as?", "This will help you with better matches", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),
                const SizedBox(height: 50,),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OptionChildrenBuilder("Male", "Gender", onOptionSelected),
                            const SizedBox(height: 10,),
                            OptionChildrenBuilder("Female", "Gender", onOptionSelected),
                            const SizedBox(height: 10,),
                            OptionChildrenBuilder("Others", "Gender", onOptionSelected),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30,),
                Text("Skip", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),)
              ],
            ),
          )
        ],
      ),
    );
  }
}


class HeightContainer extends StatefulWidget {
  final VoidCallback moveAction;

  const HeightContainer({Key? key, required this.moveAction}) : super(key: key);

  @override
  State<HeightContainer> createState() => _HeightContainerState();
}

class _HeightContainerState extends State<HeightContainer> {
  @override
  String heightValue = "Choose your height";
  
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                titleAndSubtitle("What is your height?", "Let's get to know you better", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),
                const SizedBox(height: 50,),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white)
                  ),
                  child: GestureDetector(
                    onTap: (){
                      showCupertinoModalPopup(context: context, builder: (BuildContext context) => SizedBox(
                        height: 250,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white
                          ),
                          child: CupertinoPicker(
                            backgroundColor: Colors.white,
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(),
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
                              widget.moveAction();
                              setState(() {
                                heightValue = "${value+150} cm";
                              });
                              userDataTags["height"] = "${value+150} cm";
                            },
                          ),
                        ),
                      ));
                    },
                    child: Center(
                      child: Text(heightValue, style: GoogleFonts.poppins(color:  Colors.white, fontSize: 20),),
                    ),
                  ),

                ),

              ],
            ),
          )
        ],
      ),
    );
  }
}

class DrinkingContainer extends StatelessWidget {
  final Function()? onOptionSelected;

  const DrinkingContainer({Key? key, this.onOptionSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                titleAndSubtitle("Do you drink?", "Let's get to know you better", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),

                const SizedBox(height: 50,),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OptionChildrenBuilder("Frequently", "Drinking", onOptionSelected),
                            const SizedBox(height: 10,),
                            OptionChildrenBuilder("Socially", "Drinking", onOptionSelected),
                            const SizedBox(height: 10,),
                            OptionChildrenBuilder("Rarely", "Drinking", onOptionSelected),
                            const SizedBox(height: 10,),
                            OptionChildrenBuilder("Never", "Drinking", onOptionSelected),
                            const SizedBox(height: 10,),
                            OptionChildrenBuilder("Sober", "Drinking", onOptionSelected),
                            const SizedBox(height: 10,),
                            OptionChildrenBuilder("Skip", "Drinking", onOptionSelected),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30,),
                Text("Skip", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),)
              ],
            ),
          )
        ],
      ),
    );
  }
}

class YearStreamContainerNew extends StatefulWidget {
  final VoidCallback moveAction;

  const YearStreamContainerNew({super.key, required this.moveAction});

  @override
  State<YearStreamContainerNew> createState() => _YearStreamContainerNewState();
}

class _YearStreamContainerNewState extends State<YearStreamContainerNew> {
  String yearValue = "Year"; 
  String streamValue = "Stream"; 

  bool _streamSelected = false;
  bool _yearSelected = false;

  final List<String> yearList = [
    "1st year",
    "2nd year",
    "3rd year",
    "4th year",
    "5th year"
  ];

  final List<String> streamsData = [
    'BBA',
    'LLB',
    'BA',
    'B.Arch',
    'B.Sc',
    'BBA',
    'B.Com',
    'BCA',
    'BHM',
    'LLB',
    'B.Tech',
    'B.Des',
    'BFA',
    'M.Arch',
    'M.Des',
    'M.FA',
    'M.Plan',
    'M.A',
    'M.Sc',
    'M.Tech',
    'LLM',
    'MBA',
    'PhD',
  ];
  @override
  Widget build(BuildContext context) {

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      titleAndSubtitle("Select your stream and year", "This can you help you with better matchmaking", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),
      const SizedBox(height: 30,),
      Container(
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                showCupertinoModalPopup(context: context, builder: (BuildContext context) => SizedBox(
                  height: 250,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white
                    ),
                    child: CupertinoPicker(
                      backgroundColor: Colors.white,
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                        initialItem: 10
                      ),
                      children: streamsData.map((stream) {
                        return Text(
                          stream,
                          style: GoogleFonts.poppins(),
                        );
                      }).toList(),
                      onSelectedItemChanged: (value) {

                        _streamSelected = true;

                        if (_yearSelected)
                          widget.moveAction();

                        userDataTags["stream"] = streamsData[value];
                        setState(() {
                          streamValue = streamsData[value];
                        });
                      },
                    ),
                  ),
                ));
              },

              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Text(streamValue, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
              ),
            ),
            const SizedBox(width: 10,),
            
            
            GestureDetector(
              onTap: () {
                showCupertinoModalPopup(context: context, builder: (BuildContext context) => SizedBox(
                    height: 250,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white
                      ),
                      child: CupertinoPicker(
                        backgroundColor: Colors.white,
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: 2
                        ),
                        children: yearList.map((stream) {
                          return Text(
                            stream,
                            style: GoogleFonts.poppins(),
                          );
                        }).toList(),
                        onSelectedItemChanged: (value) {

                        _yearSelected = true;

                        if (_streamSelected)
                          widget.moveAction();

                          userDataTags["year"] = value+1;
                          setState(() {
                            yearValue = yearList[value];
                          });
                        },
                      ),
                    ),
                  ));
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Text(yearValue, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
              ),
            ),
          ],
        ),
      )
    ],
  );
  }
}

Widget YearStreamContainer(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      titleAndSubtitle("Select your stream and year", "This can you help you with better matchmaking", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),
      const SizedBox(height: 30,),
      Container(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(5)
              ),
              child: Text("Stream", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
            ),
            const SizedBox(width: 10,),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(5)
              ),
              child: Text("Year", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
            ),
          ],
        ),
      )
    ],
  );
}

class DateContainerNew extends StatefulWidget {
  final VoidCallback moveAction;

  const DateContainerNew({super.key, required this.moveAction});

  @override
  State<DateContainerNew> createState() => _DateContainerNewState();
}

class _DateContainerNewState extends State<DateContainerNew> {
  DateTime? dateTime;
  DateTime maximumDate = DateTime.now().subtract(const Duration(days: 18 * 365)); // Subtracting 18 years
  String dateDay = "DD";
  String dateMonth = "MM";
  String dateYear = "YY";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        titleAndSubtitle("When were you born?", "Users above 18 can only use MUJDating", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),
        const SizedBox(height: 30,),
        GestureDetector(
          onTap: () {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => SizedBox(
                height: 250,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  color: Colors.white,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    backgroundColor: Colors.white,
                    initialDateTime: DateTime(2001),
                    minimumDate: DateTime(1990),
                    maximumDate: maximumDate,
                    onDateTimeChanged: (DateTime value) {
                      setState(() {
                        widget.moveAction();
                        dateTime = value;
                        if (dateTime != null) {
                          DateTime currentDate = DateTime.now();
                          int age = currentDate.year - dateTime!.year;
                          
                          if (currentDate.month < dateTime!.month || (currentDate.month == dateTime!.month && currentDate.day < dateTime!.day)) {
                            age--;
                          }
                          
                          userDataTags["age"] = age;
                          userDataTags["dob"] = "$dateDay-$dateMonth-$dateYear";
                        }

                        dateDay = value.day.toString();
                        dateMonth = value.month.toString();
                        dateYear = value.year.toString();
                      });
                    },
                  ),
                ),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 17),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(dateDay, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 17),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(dateMonth, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 21),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(dateYear, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget NameContainer(bool isContainerEnabled, TextEditingController nameController) {
  return Column(
    children: [
      titleAndSubtitle("What do you want people to call you?", "Your name cannot be changed afterwards", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),
              
      const SizedBox(height: 30,),

      TextField(
        controller: nameController, // Assign the controller
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: 'Enter your name',
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Color(0xFFFFC629)),
          ),
        ),
      ),
    ],
  );
}

Widget NextButton(bool isContainerEnabled, TextEditingController nameController, int counter, VoidCallback startAnimation){
  return Align(
    alignment: Alignment.bottomRight,
    child: FloatingActionButton(
      backgroundColor: isContainerEnabled ? const Color(0xFFFFC629) : Colors.grey,
      onPressed: isContainerEnabled
          ? () {
              userDataTags["name"] = nameController.text.trim();
              startAnimation();
            }
          : null,
      shape: const CircleBorder(),
      child: const Icon(Icons.done_rounded, color: Colors.white),
    ),
  );
}

Map userDataTags = {
  "uid": FirebaseAuth.instance.currentUser?.uid,
  'type': 'CreateUserMetaDetails',
};

Widget OptionChildrenBuilder(String optionText, String Type, [Function()? onOptionSelected]) {
  return GestureDetector(
    onTap: () {
      switch(Type){
        case "Drinking":
          userDataTags["drinkingStatus"] = optionText;
          break;
        case "Religion":
          userDataTags["religionStatus"] = optionText;
          break;
        case "LookingFor":
          userDataTags["datingStatus"] = optionText;
          break;
        case "Smoking":
          userDataTags["smokingStatus"] = optionText;
          break;
      }
      if (onOptionSelected != null) {
        onOptionSelected(); 
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 233, 233, 233)),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Center(
        child: Text(
          optionText,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w400,),
        ),
      ),
    ),
  );
}
