// ignore_for_file: camel_case_types, library_private_types_in_public_api, use_super_parameters
import 'package:flutter/services.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/elements/create_profile_elements/elements.dart';
import 'package:linkup/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shake_flutter/shake_flutter.dart';

class createUserProfile extends StatefulWidget {
  const createUserProfile({Key? key}) : super(key: key);

  @override
  _createUserProfileState createState() => _createUserProfileState();
}

class _createUserProfileState extends State<createUserProfile> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _controller;
  bool _isContainerEnabled = false;
  int counter = 1;

  @override
  void initState() {
    super.initState();
    ApiCalls.fetchCookieDoggie(true);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _nameController.addListener(_textFieldListener);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void startAnimation() {
    setState(() {
      _isContainerEnabled = false;
      counter++;
    });
  }

  void _textFieldListener() {
    setState(() {
      _isContainerEnabled = _nameController.text.trim().isNotEmpty;
    });
  }

  void valueCheck() {
    setState(() {
      _isContainerEnabled = true;
    });
  }

  void valueReject(){
    setState(() {
      _isContainerEnabled = false;
    });
  }

  void _onCompletion() async{
    var userMetaDataForShaketoReport = <String,String>{
      "first_name" : userDataTags["name"]
    };

    Shake.updateUserMetadata(userMetaDataForShaketoReport);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );  
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).colorScheme.surface,
        statusBarIconBrightness: UserValues.darkTheme ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(counter != 19)
                  // Text("Create your profile", style: GoogleFonts.poppins(fontSize: 20, color: Colors.white)),
                  if (counter % 2 == 0 || counter == 1)...[
                    ProgressBars(progressCount: counter,),
                  ]
                  else...[
                    ProgressBars(progressCount: counter-1,),

                  ],

                const SizedBox(height: 40,),
                if (counter == 1)
                  Expanded(
                    child: Column(
                      children: [
                        Animate(
                          autoPlay: false,
                          child: NameContainer(_isContainerEnabled, _nameController),
                        ).slideX(end: -0.2,).fadeOut(duration: const Duration(milliseconds: 200)),
                        const Spacer(),
                        NextButton(_isContainerEnabled, _nameController, counter, startAnimation),
                      ],
                    ),
                  ),
                if (counter == 2)
                  Expanded(
                    child: Column(
                      children: [
                        Animate(
                          controller: _controller,
                          child: DateContainerNew(moveAction: valueCheck),
                        ).fadeIn(duration: const Duration(milliseconds: 200)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 200), curve: Curves.easeIn),
                        const Spacer(),
                        NextButton(_isContainerEnabled, _nameController, counter, startAnimation)
                      ],
                    ),
                  ),
      
                if (counter == 3)
                  Animate(
                    onComplete: (controller) {
                      setState(() {
                        counter = 4; 
                      });
                    },
                    child: DateContainerNew(moveAction: valueCheck),
                  ).slideX(end: -0.2).fadeOut(duration: const Duration(milliseconds: 100)),
      
                if (counter == 4)
                  Expanded(
                    child: Column(
                      children: [
                        Animate(
                          child: YearStreamContainerNew(moveAction: valueCheck),
                        ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
                        const Spacer(),
                        NextButton(_isContainerEnabled, _nameController, counter, startAnimation)
                      ],
                    ),
                  ),
                if (counter == 5)
                  Animate(
                    onComplete: (controller) {
                      setState(() {
                        counter = 6; 
                      });
                    },
                    child: YearStreamContainerNew(moveAction: valueCheck),
                  ).slideX(end: -0.2).fadeOut(duration: const Duration(milliseconds: 100)),
      
                if (counter == 6)
                  Expanded(
                    child: Column(
                      children: [
                        Animate(
                    child: HeightContainer(moveAction: valueCheck,),
                        ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
                          const Spacer(),
                          NextButton(_isContainerEnabled, _nameController, counter, startAnimation)
                      ],
                    ),
                  ),
                if (counter == 7)
                  Animate(
                    onComplete: (controller) {
                      setState(() {
                        counter = 8; 
                      });
                    },
                    child: HeightContainer(moveAction: valueCheck,),
                  ).slideX(end: -0.2).fadeOut(duration: const Duration(milliseconds: 100)),
                if (counter == 8)
                  Animate(
                    child: GenderContainer(onOptionSelected: startAnimation),
                  ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
                if (counter == 9)
                  Animate(
                    onComplete: (controller) {
                      setState(() {
                        counter = 10; 
                      });
                    },
                    child: GenderContainer(onOptionSelected: startAnimation),
                  ).slideX(end: -0.2).fadeOut(duration: const Duration(milliseconds: 100)),
      
      
                if (counter == 10)
                  Animate(
                    child: DrinkingContainer(onOptionSelected: startAnimation),
                  ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
                if (counter == 11)
                  Animate(
                    onComplete: (controller) {
                      setState(() {
                        counter = 12; 
                      });
                    },
                    child: DrinkingContainer(onOptionSelected: startAnimation),
                  ).slideX(end: -0.2).fadeOut(duration: const Duration(milliseconds: 100)),
      
                
                if (counter == 12)
                  Animate(
                    child: SmokingContainer(onOptionSelected: startAnimation),
                  ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
                if (counter == 13)
                  Animate(
                    onComplete: (controller) {
                      setState(() {
                        counter = 14; 
                      });
                    },
                    child: SmokingContainer(onOptionSelected: startAnimation),
                  ).slideX(end: -0.2).fadeOut(duration: const Duration(milliseconds: 100)),
      
                if (counter == 14)
                  Animate(
                    child: LookingForContainer(onOptionSelected: startAnimation),
                  ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
                if (counter == 15)
                  Animate(
                    onComplete: (controller) {
                      setState(() {
                        counter = 16; 
                      });
                    },
                    child: LookingForContainer(onOptionSelected: startAnimation),
                  ).slideX(end: -0.2).fadeOut(duration: const Duration(milliseconds: 100)),
                if (counter == 16)
                  Animate(
                    child: ReligionContainer(onOptionSelected: startAnimation),
                  ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
                if (counter == 17)
                  Animate(
                    onComplete: (controller) {
                      setState(() {
                        counter = 18; 
                      });
                    },
                    child: ReligionContainer(onOptionSelected: startAnimation),
                  ).slideX(end: -0.2).fadeOut(duration: const Duration(milliseconds: 100)),
                if (counter == 18)
                  Animate(
                  child: Expanded(
                    child: Column(
                      children: [
                        PhotoContainer(moveAction: valueCheck, valueReject: valueReject),
                        const Spacer(),
                        NextButton(_isContainerEnabled, _nameController, counter, startAnimation, uploadImageBool: true, onCompletion: _onCompletion),
                      ],
                    ),
                  ),
                ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
      
                if (counter == 19)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 70, width: 70, child: CircularProgressIndicator()),
                          const SizedBox(height: 50,),
                          Text("Uploading your data :)", style: GoogleFonts.poppins(color: Colors.white),)
                        ],
                      ),
                    ),
                  ).animate().fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<int> indexTracker = [];
late int prevCounter= 0;

class ProgressBars extends StatefulWidget {
  final int progressCount;

  const ProgressBars({super.key, required this.progressCount});

  @override
  State<ProgressBars> createState() => _ProgressBarsState();
}

class _ProgressBarsState extends State<ProgressBars> {
  @override
  Widget build(BuildContext context) {
    // Calculate width of each container dynamically
    double containerWidth = MediaQuery.of(context).size.width / 7;
    
    if (prevCounter == widget.progressCount){
      print("Prev Shit");
    }
    else{
      prevCounter = widget.progressCount;

      int indexToAdd = indexTracker.length * 2;
      indexTracker.add(indexToAdd);
      print(indexTracker);
    }
    

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 10,
        child: Row(
          children: List.generate(11 * 2 - 1, (index) {
            if (index.isEven) {
              // Index is even, return Expanded container
              return Expanded(
                child: Container(
                  width: containerWidth,
                  decoration: BoxDecoration(
                    color: (indexTracker.contains(index))? Color.fromARGB(255, 0, 173, 170) : Colors.grey, // Change color or style as needed
                    borderRadius: BorderRadius.circular(20)
                  ),
                ),
              );
            } else {
              // Index is odd, return SizedBox for gap
              return const SizedBox(width: 10); // Adjust gap size as needed
            }
          }),
        ),
      ),
    );
  }
}