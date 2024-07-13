import 'package:flutter/services.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/UI/elements/profile_elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditGender extends StatefulWidget {
  final String title;
  final IconData type;
  final String data;

  const EditGender({
    super.key,
    required this.title,
    required this.type,
    required this.data,
  });

  @override
  State<EditGender> createState() => EditGenderState();
}

class GenderBuilder extends StatelessWidget {
  final String gender;
  final int index;
  final bool isSelected;
  final Function(int) onTap;

  const GenderBuilder({
    super.key,
    required this.gender,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              gender,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            isSelected
                ? const Icon(
                    Icons.radio_button_checked,
                  )
                : const Icon(
                    Icons.radio_button_unchecked_rounded,
                  ),
          ],
        ),
      ),
    );
  }
}

class EditGenderState extends State<EditGender> {
  List<bool> isSelected = [false, false, false];
  List<String> genderList = ["Female", "Male", "Others"];

  @override
  void initState() {
    super.initState();
    initialValueSetter();
  }

  void initialValueSetter(){
    switch (widget.data){
      case "Female":
        tapThen(0);
        break;
      case "Male":
        tapThen(1);
        break;
      case "Others":
        tapThen(2);
        break;
    }
  }

  void tapThen(int index) {
    setState(() {
      for (int i = 0; i < isSelected.length; i++) {
        isSelected[i] = i == index;
      }
    });

    Map userDataTags = {
      "uid": UserValues.uid,
      'type': 'uploadTagData',
      'key': UserValues.cookieValue,
      'keyToUpdate': "gender",
      'value': genderList[index]
    };

    ApiCalls.storeUserMetaData(userDataTags);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.surface
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleAndSubtitle("Choose your ${widget.title.toLowerCase()}", "Select your ${widget.title.toLowerCase()}"),
              const SizedBox(height: 30),
              SizedBox(
                height: 400,
                child: Column(
                  children: [
                    GenderBuilder(
                      gender: "Female",
                      index: 0,
                      isSelected: isSelected[0],
                      onTap: tapThen,
                    ),
                    const SizedBox(height: 20),
                    GenderBuilder(
                      gender: "Male",
                      index: 1,
                      isSelected: isSelected[1],
                      onTap: tapThen,
                    ),
                    const SizedBox(height: 20),
                    GenderBuilder(
                      gender: "Others",
                      index: 2,
                      isSelected: isSelected[2],
                      onTap: tapThen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
