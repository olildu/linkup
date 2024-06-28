import 'dart:io';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/api/common_functions.dart';
import 'package:linkup/elements/profile_elements/elements.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

Map<String, File?> images = {
  "image0": null,
  "image1": null,
  "image2": null,
  "image3": null,
};

class LookingForContainer extends StatelessWidget {
  final Function()? onOptionSelected;

  const LookingForContainer({super.key, this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20,),
              // titleAndSubtitle("What do you want from dates?", "Let's get to know you better", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),
          
              Title("What do you want from dates?"),
              const SizedBox(height: 10,),
              Subtitle("Let's get to know you better"),

              const SizedBox(height: 40,),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OptionChildrenBuilder(context,"Relationship", "LookingFor", onOptionSelected),
                          const SizedBox(height: 10,),
                          OptionChildrenBuilder(context,"Something Casual", "LookingFor", onOptionSelected),
                          const SizedBox(height: 10,),
                          OptionChildrenBuilder(context,"Don't know yet", "LookingFor", onOptionSelected),
                          const SizedBox(height: 10,),
                          OptionChildrenBuilder(context,"Skip", "LookingFor", onOptionSelected),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          
              const SizedBox(height: 30,),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              const SizedBox(height: 20,),
              // titleAndSubtitle("Do you identify with a religion?", "Let's get to know you better", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),
            
              Title("Do you identify with a religion?"),
              const SizedBox(height: 10,),
              Subtitle("Let's get to know you better"),

              const SizedBox(height: 50,),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6, // Adjust the height as needed
                  child: ListView(
                    children: [
                      OptionChildrenBuilder(context,"Agnostic", "Religion", onOptionSelected),
                      const SizedBox(height: 10,),
                      OptionChildrenBuilder(context,"Atheist", "Religion", onOptionSelected),
                      const SizedBox(height: 10,),
                      OptionChildrenBuilder(context,"Buddhist", "Religion", onOptionSelected),
                      const SizedBox(height: 10,),
                      OptionChildrenBuilder(context,"Catholic", "Religion", onOptionSelected),
                      const SizedBox(height: 10,),
                      OptionChildrenBuilder(context,"Christian", "Religion", onOptionSelected),
                      const SizedBox(height: 10,),
                      OptionChildrenBuilder(context,"Hindu", "Religion", onOptionSelected),
                      const SizedBox(height: 10,),
                      OptionChildrenBuilder(context,"Jain", "Religion", onOptionSelected),
                      const SizedBox(height: 10,),
                      OptionChildrenBuilder(context,"Jewish", "Religion", onOptionSelected),
                      const SizedBox(height: 10,),
                      OptionChildrenBuilder(context,"Mormon", "Religion", onOptionSelected),
                      const SizedBox(height: 10,),
                      OptionChildrenBuilder(context,"Muslim", "Religion", onOptionSelected),
                      const SizedBox(height: 10,),
                      OptionChildrenBuilder(context,"Sikh", "Religion", onOptionSelected),
                      const SizedBox(height: 10,),
                      OptionChildrenBuilder(context,"Other", "Religion", onOptionSelected),
                      const SizedBox(height: 10,),
                      OptionChildrenBuilder(context,"Skip", "Religion", onOptionSelected),
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

class SmokingContainer extends StatelessWidget {
  final Function()? onOptionSelected;

  const SmokingContainer({super.key, this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20,),
              // titleAndSubtitle("Do you smoke?", "Let's get to know you better", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),

              Title("Do you smoke?"),
              const SizedBox(height: 10,),
              Subtitle("Let's get to know you better"),

              const SizedBox(height: 40,),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OptionChildrenBuilder(context,"Socially", "Smoking", onOptionSelected),
                          const SizedBox(height: 10,),
                          OptionChildrenBuilder(context,"Regularly", "Smoking", onOptionSelected),
                          const SizedBox(height: 10,),
                          OptionChildrenBuilder(context,"Never", "Smoking", onOptionSelected),
                          const SizedBox(height: 10,),
                          OptionChildrenBuilder(context,"Skip", "Smoking", onOptionSelected),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class GenderContainer extends StatelessWidget {
  final Function()? onOptionSelected;

  const GenderContainer({super.key, this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20,),
              // titleAndSubtitle("What do you identify as?", "This will help you with better matches", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),

              Title('What do you identify as?'),
              const SizedBox(height: 10,),
              Subtitle("This will help you with better matches"),
              
              const SizedBox(height: 40,),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OptionChildrenBuilder(context,"Male", "Gender", onOptionSelected),
                          const SizedBox(height: 10,),
                          OptionChildrenBuilder(context,"Female", "Gender", onOptionSelected),
                          const SizedBox(height: 10,),
                          OptionChildrenBuilder(context,"Others", "Gender", onOptionSelected),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class HeightContainer extends StatefulWidget {
  final VoidCallback moveAction;

  const HeightContainer({super.key, required this.moveAction});

  @override
  State<HeightContainer> createState() => _HeightContainerState();
}

class _HeightContainerState extends State<HeightContainer> {
  String heightValue = "Choose your height";
  
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          GestureDetector(
            onTap: (){
              showCupertinoModalPopup(context: context, builder: (BuildContext context) => SizedBox(
                height: 250,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface
                  ),
                  child: CupertinoPicker(
                    backgroundColor: Theme.of(context).colorScheme.surface,
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
            child: Container(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20,),
                  // titleAndSubtitle("What is your height?", "Let's get to know you better", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),

                  Title("What is your height?"),
                  const SizedBox(height: 10,),
                  Subtitle("Let's get to know you better"),

                  const SizedBox(height: 40,),
            
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
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface
                            ),
                            child: CupertinoPicker(
                              backgroundColor: Theme.of(context).colorScheme.surface,
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
            ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20,),
              // titleAndSubtitle("Do you drink?", "Let's get to know you better", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),

              Title("Do you drink?"),
              const SizedBox(height: 10,),
              Subtitle("Let's get to know you better"),
          
              const SizedBox(height: 40,),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OptionChildrenBuilder(context,"Frequently", "Drinking", onOptionSelected),
                          const SizedBox(height: 10,),
                          OptionChildrenBuilder(context,"Socially", "Drinking", onOptionSelected),
                          const SizedBox(height: 10,),
                          OptionChildrenBuilder(context,"Rarely", "Drinking", onOptionSelected),
                          const SizedBox(height: 10,),
                          OptionChildrenBuilder(context,"Never", "Drinking", onOptionSelected),
                          const SizedBox(height: 10,),
                          OptionChildrenBuilder(context,"Sober", "Drinking", onOptionSelected),
                          const SizedBox(height: 10,),
                          OptionChildrenBuilder(context,"Skip", "Drinking", onOptionSelected),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
      // titleAndSubtitle("Select your stream and year", "This can you help you with better matchmaking", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),
      
      Title("Select your stream and year"),
      const SizedBox(height: 10,),
      Subtitle("This can you help you with better matchmaking"),
      
      const SizedBox(height: 30,),
      Row(
        children: [
          GestureDetector(
            onTap: () {
              showCupertinoModalPopup(context: context, builder: (BuildContext context) => SizedBox(
                height: 250,
                child: Container(
                  decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface
                  ),
                  child: CupertinoPicker(
                    backgroundColor: Theme.of(context).colorScheme.surface,
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
                         
                      if (_yearSelected) {
                        widget.moveAction();
                      }
      
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
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface
                    ),
                    child: CupertinoPicker(
                      backgroundColor: Theme.of(context).colorScheme.surface,
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
      
                      if (_streamSelected) {
                        widget.moveAction();
                      }
      
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
      Row(
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
        // titleAndSubtitle("When were you born?", "Users above 18 can only use linkup", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),
        
        Title("When were you born?"),
        const SizedBox(height: 10,),
        Subtitle("Users above 18 can only use linkup"),

        const SizedBox(height: 30,),
        GestureDetector(
          onTap: () {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => SizedBox(
                height: 250,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    initialDateTime: DateTime(2001),
                    minimumDate: DateTime(1990),
                    maximumDate: maximumDate,
                    onDateTimeChanged: (DateTime value) {
                      setState(() {
                        widget.moveAction();
                        dateTime = value;

                        dateDay = value.day.toString();
                        dateMonth = value.month.toString();
                        dateYear = value.year.toString();
                        
                        if (dateTime != null) {
                          DateTime currentDate = DateTime.now();
                          int age = currentDate.year - dateTime!.year;
                          
                          if (currentDate.month < dateTime!.month || (currentDate.month == dateTime!.month && currentDate.day < dateTime!.day)) {
                            age--;
                          }
                          
                          userDataTags["age"] = age;
                          userDataTags["dob"] = "$dateDay-$dateMonth-$dateYear";
                        }
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
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // titleAndSubtitle("What do you want people to call you?", "Your name cannot be changed afterwards", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),

      Text(
        "What do you want people to call you?", 
        style: GoogleFonts.poppins(
          fontSize: 35,
          fontWeight: FontWeight.w600
        ),
      ),           

      const SizedBox(height: 30,),

      TextField(
        controller: nameController, // Assign the controller
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(color: Colors.black), // Set text color to black
        decoration: InputDecoration(
          hintText: 'Enter your name',
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
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

Widget NextButton(bool isContainerEnabled, TextEditingController nameController, int counter, VoidCallback moveCounter, {bool? uploadImageBool, VoidCallback? onCompletion}) {
  print(userDataTags);
  return Align(
    alignment: Alignment.bottomRight,
    child: FloatingActionButton(
      backgroundColor: isContainerEnabled ? const Color(0xFFFFC629) : Colors.grey,
      onPressed: isContainerEnabled
          ? () async {
              userDataTags["name"] = nameController.text.trim();
              moveCounter(); // Call moveCounter function to go to the next counter by calling counter++;
              if (uploadImageBool != null && uploadImageBool) {
                userDataTags["key"] = UserValues.cookieValue;

                Map imageNames = {}; // {File : image+md5hash.jpg}
                
                // Naming images "image+md5hash.jpg"
                await Future.wait(images.values.whereType<File>().map((value) async {
                  imageNames[value] = await CommonFunction().returnmd5Hash(value);
                }));

                /* imageUploadHandler will handle image uploads by taking imageNames map which has value as File and keys as 
                the image name which is image+md5hash.jpg and then parallelly run uploads of file for example if two images 
                are picked then image1 and image2 will be both uploaded parallely to the server along with their blurHashing
                */

                await imageUploadHandler(imageNames); 

                // Upload userTag and Basic Data to the server using API call
                ApiCalls.storeUserMetaData(userDataTags);
                
                // Once upload is complete remove the animation and then proceed to the MainPage() 
                onCompletion!();
              }
            }
          : null,
      shape: const CircleBorder(),
      child: const Icon(Icons.done_rounded, color: Colors.white),
    ),
  );
}

Future<void> imageUploadHandler(Map imageNames) async {
  print(imageNames);
  List<Future<void>> uploadTasks = [];
  List imageNamesList = imageNames.values.toList();
  List fileNamesList = imageNames.keys.toList();
  
  for (int x = 0; x < imageNamesList.length; x++) {
    uploadTasks.add(ImageUpload(x, imageNamesList[x], fileNamesList[x])); // Add tasks to the list to run these in parallel
  }

  await Future.wait(uploadTasks);
}

Future<void> ImageUpload(int orderNumber, String imageName, file) async {
  await FirebaseCalls.uploadImage(file, imageName); // First uploadImage

  Map data = {
    "key": UserValues.cookieValue,
    "uid": UserValues.uid,
    "orderNumber": orderNumber,
    "imageName": imageName,
    "url": "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${UserValues.uid}%2F$imageName?alt=media&token"
  };

  await ApiCalls.mapValuesHashDatabase(data); // Then hash the blurHash and save to the database with hashMappings
} 

Map userDataTags = {
  "uid": FirebaseAuth.instance.currentUser?.uid,
  'type': 'CreateUserMetaDetails',
};

Widget OptionChildrenBuilder(BuildContext context, String optionText, String Type, [Function()? onOptionSelected]) {
  return GestureDetector(
    onTap: () {
      if (optionText == "Skip"){
        onOptionSelected!(); 
        return;
      }
      switch(Type){
        case "Drinking":
          userDataTags["drinkingStatus"] = optionText;
          break;
        case "Religion":
          userDataTags["religionStatus"] = optionText;
          break;
        case "LookingFor":
          userDataTags["lookingFor"] = optionText;
          break;
        case "Smoking":
          userDataTags["smokingStatus"] = optionText;
          break;
        case "Gender":
          userDataTags["gender"] = optionText;
          break;
      }
      if (onOptionSelected != null) {
        onOptionSelected(); 
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        border: Border.all(color: Theme.of(context).colorScheme.secondary,),
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

class PhotoContainer extends StatefulWidget {
  final VoidCallback moveAction;
  final VoidCallback valueReject;

  const PhotoContainer({super.key, required this.moveAction, required this.valueReject});

  @override
  State<PhotoContainer> createState() => _PhotoContainerState();
}

class _PhotoContainerState extends State<PhotoContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20,),
                  // titleAndSubtitle("Add your Photos", "Add photos that show your true self", titleColor: Colors.white, subTitleColor: const Color(0xFFC0C0C0)),

                  Title("Add your Photos"),
                  const SizedBox(height: 10,),
                  Subtitle("Add photos that show your true self"),
              
                  const SizedBox(height: 40,),
              
                  PhotosWidget(moveAction: widget.moveAction, valueReject: widget.valueReject)
              
                ],
              )
            ],
          ),
        );
  }
}

class PhotosWidget extends StatefulWidget {
  final VoidCallback moveAction;
  final VoidCallback valueReject;

  const PhotosWidget({super.key, required this.moveAction, required this.valueReject});
  @override
  PhotosWidgetState createState() => PhotosWidgetState();
}

class PhotosWidgetState extends State<PhotosWidget> {
  int counter = 0;

  Future confirmationPopup(BuildContext context, int index){
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: CupertinoPopupSurface(
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white
              ),
              child: Column(
                children: [
                  CupertinoButton(child: Text("Delete Photo", style: GoogleFonts.poppins(color: const Color.fromARGB(255, 218, 37, 24), fontSize: 20),), onPressed: (){
                    setState(() {
                      counter--;
                      if (counter > 0){
                        widget.moveAction();
                      }
                      if (counter == 0){
                        widget.valueReject();
                      }
                      switch (index) {
                        case 0:
                          for (int x = 0; x < 3; x++) {
                            images["image$x"] = images["image${x + 1}"];
                          }
                          images["image3"] = null;
                          break;
                        case 1:
                          for (int x = 1; x < 3; x++) {
                            images["image$x"] = images["image${x + 1}"];
                          }
                          images["image3"] = null;
                          break;
                        case 2:
                          images["image2"] = images["image3"];
                          images["image3"] = null;
                          break;
                        case 3:
                          images["image3"] = null;
                          break;
                        default:
                          break;
                      }
                      Navigator.of(context).pop();

                    });
                  }),
                  CupertinoButton(child: Text("Dismiss", style: GoogleFonts.poppins(color: Colors.black, fontSize: 20),), onPressed: (){
                    Navigator.of(context).pop();
                  }),
                ],
              )),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, int imageIndex) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source, imageQuality: 50);
    if (pickedImage != null) {
      setState(() {
        if (counter > 0){
          widget.moveAction();
        }
        if (counter == 0){
          widget.valueReject();
        }
        switch (imageIndex) {
          case 0:
            images["image0"] = File(pickedImage.path);
            break;
          case 1:
            if (images["image0"] == null) {
              images["image0"] = File(pickedImage.path);
            } else {
              images["image1"] = File(pickedImage.path);
            }
            break;
          case 2:
            if (images["image0"] == null) {
              images["image0"] = File(pickedImage.path);
            } else if (images["image1"] == null) {
              images["image1"] = File(pickedImage.path);
            } else {
              images["image2"] = File(pickedImage.path);
            }
            break;
          case 3:
            if (images["image0"] == null) {
              images["image0"] = File(pickedImage.path);
            } else if (images["image1"] == null) {
              images["image1"] = File(pickedImage.path);
            } else if (images["image2"] == null) {
              images["image2"] = File(pickedImage.path);
            } else {
              images["image3"] = File(pickedImage.path);
            }
            break;
          default:
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450,
      child: FractionallySizedBox(
        heightFactor: 1,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 16,
                    child: GestureDetector(
                      onTap: () async {
                        if (images["image0"] != null) {
                          confirmationPopup(context, 0);
                        }
                        else{
                          counter++;
                          await _pickImage(ImageSource.gallery, 0);
                        }
                      },
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        color: const Color.fromARGB(255, 175, 175, 175),
                        radius: const Radius.circular(12),
                        padding: const EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: images["image0"] != null
                                ? Image.file(
                                    images["image0"]!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.add_rounded, size: 50, color: Colors.white,),
                            ),
                          ),
                      )
                      ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 10,
                    child: GestureDetector(
                      onTap: () async {
                        if (images["image1"] != null) {
                          confirmationPopup(context, 1);
                        }
                        else{
                          counter++;
                          await _pickImage(ImageSource.gallery, 1);
                        }
                      },
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        color: const Color.fromARGB(255, 175, 175, 175),
                        radius: const Radius.circular(12),
                        padding: const EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          child: images["image1"] != null
                            ? Image.file(
                                images["image1"]!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.add_rounded, size: 50, color: Colors.white,),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: GestureDetector(
                      onTap: () async {
                        if (images["image2"] != null) {
                          confirmationPopup(context, 2);
                        }
                        else{
                          counter++;
                          await _pickImage(ImageSource.gallery, 2);
                        }
                      },
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        color: const Color.fromARGB(255, 175, 175, 175),
                        padding: const EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          child: images["image2"] != null
                            ? Image.file(
                                images["image2"]!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.add_rounded, size: 50, color: Colors.white,),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 16,
                    child: GestureDetector(
                      onTap: () async {
                        if (images["image3"] != null) {
                          confirmationPopup(context, 3);
                        }
                        else{
                          counter++;
                          await _pickImage(ImageSource.gallery, 3);
                        }
                      },
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        padding: const EdgeInsets.all(4),
                        color: const Color.fromARGB(255, 175, 175, 175),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          child: images["image3"] != null
                            ? Image.file(
                                images["image3"]!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.add_rounded, size: 50, color: Colors.white,),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget Title(String title){
  return Text(
  title, 
  style: GoogleFonts.poppins(
    fontSize: 35,
    fontWeight: FontWeight.w600
  ),
  );
}

Widget Subtitle(String title){
  return Text(
  title, 
  style: GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w300
  ),
  );
}