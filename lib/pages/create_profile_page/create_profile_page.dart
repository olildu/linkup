// ignore_for_file: camel_case_types, library_private_types_in_public_api, use_super_parameters

import 'package:demo/api/api_calls.dart';
import 'package:demo/elements/create_profile_elements/elements.dart';
import 'package:demo/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class createUserProfile extends StatefulWidget {
  createUserProfile({Key? key}) : super(key: key);

  @override
  _createUserProfileState createState() => _createUserProfileState();
}

class _createUserProfileState extends State<createUserProfile>{
  final TextEditingController _nameController = TextEditingController();
  bool _isContainerEnabled = false;
  int counter = 1;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_textFieldListener);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void startAnimation() {
    setState(() {
      _isContainerEnabled = false;
      counter++;
    });
    if (counter == 17)
      _onCompletion();
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

  void _onCompletion() async{
    userDataTags["key"] = userValues.cookieValue;
    await ApiCalls.uploadUserData(userDataTags);
    print("Pushed");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => mainPage()),
    );  
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(12, 25, 44, 1),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(counter != 17)
                Text("Create your profile", style: GoogleFonts.poppins(fontSize: 20, color: Colors.white)),
              const SizedBox(height: 50,),
              if (counter == 1)
                Expanded(
                  child: Column(
                    children: [
                      Animate(
                        autoPlay: false,
                        // child: PhotoContainer(),
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
                        child: DateContainerNew(moveAction: valueCheck),
                      ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
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
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 70, width: 70, child: CircularProgressIndicator()),
                        const SizedBox(height: 50,),
                        Text("Uploading your data :)", style: GoogleFonts.poppins(color: Colors.white),)
                      ],
                    ),
                  ),
                ).animate().fadeIn()
                
            ],
          ),
        ),
      ),
    );
  }
}
