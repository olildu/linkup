// ignore_for_file: prefer_const_constructors

import 'package:demo/api/api_calls.dart';
import 'package:demo/elements/profile_elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditGender extends StatefulWidget {
  final String title;
  final IconData type;
  final String data;

  const EditGender({Key? key, required this.title, required this.type, required this.data}) : super(key: key);

  @override
  State<EditGender> createState() => EditGenderState();
}

class GenderBuilder extends StatefulWidget {
  final String gender;
  final int index;

  const GenderBuilder({Key? key, required this.gender, required int this.index}) : super(key: key);

  @override
  _GenderBuilderState createState() => _GenderBuilderState();
}

class _GenderBuilderState extends State<GenderBuilder> {
  bool _isSelected = false;
  final List <String> genderList = ["Female", "Male", "Others"];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
            Map userDataTags = {
              "uid": userValues.uid,
              'type': 'uploadTagData',
              'key': userValues.cookieValue,
              'keyToUpdate': "gender",
              'value': genderList[widget.index]
            };

          ApiCalls.uploadUserTagData(userDataTags);

          Navigator.pop(context);
        });
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: _isSelected ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              widget.gender,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            _isSelected
                ? Icon(
                    Icons.radio_button_checked,
                  )
                : Icon(
                    Icons.radio_button_unchecked_rounded,
                  ),
          ],
        ),
      ),
    );
  }
}



class EditGenderState extends State<EditGender> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleAndSubtitle("Choose your ${widget.title.toLowerCase()}", "Select your ${widget.title.toLowerCase()}"),
            const SizedBox(height: 30,),
            const SizedBox(
              height: 400,
              child: Column(
                children: [
                  GenderBuilder(gender: "Female", index: 0),
                  SizedBox(height: 20,),
                  GenderBuilder(gender: "Male", index: 1),
                  SizedBox(height: 20,),
                  GenderBuilder(gender: "Others", index: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

