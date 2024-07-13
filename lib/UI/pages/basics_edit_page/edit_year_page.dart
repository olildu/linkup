// ignore_for_file: prefer_const_constructors

import 'package:flutter/services.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/UI/colors/colors.dart';
import 'package:linkup/UI/elements/profile_elements/elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class EditYear extends StatefulWidget {
  final String title;
  final IconData type;
  final String data;

  const EditYear({super.key, required this.title, required this.type, required this.data});

  @override
  State<EditYear> createState() => EditYearState();
}

class EditYearState extends State<EditYear> {
  int? yearIndex;

  @override
  void initState() {
    super.initState();
    yearIndex = int.tryParse(widget.data.trim());
  }

  @override
  Widget build(BuildContext context) {
    final List<String> yearList = ["1", "2", "3", "4", "5"];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
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
              titleAndSubtitle(
                "Choose your ${widget.title.toLowerCase()}",
                "Select your ${widget.title.toLowerCase()}",
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                child: GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) => SizedBox(
                        height: 250,
                        child: CupertinoPicker(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: yearIndex ?? 0,
                          ),
                          children: yearList.map((stream) {
                            return SizedBox(
                              height: 20,
                              width: 200,
                              child: Center(
                                child: Text(
                                  stream,
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            );
                          }).toList(),
                          onSelectedItemChanged: (value) {
                            setState(() {
                              yearIndex = value + 1;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 25),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 215, 215, 215),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            yearIndex == null ? widget.data : yearIndex.toString(),
                            style: GoogleFonts.poppins(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Map userDataTags = {
              "uid": UserValues.uid,
              'type': 'uploadTagData',
              'key': UserValues.cookieValue,
              'keyToUpdate': "year",
              'value': yearIndex.toString()
            };

            ApiCalls.storeUserMetaData(userDataTags); // Upload to server

            Navigator.pop(context); // Exit from page
          }, 
          backgroundColor: ReuseableColors.accentColor, 
          shape: const CircleBorder(),
          child: ClipOval(
            child: Icon(Icons.done_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }
}