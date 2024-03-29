// ignore_for_file: prefer_const_constructors

import 'package:demo/elements/profile_elements/elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditYear extends StatefulWidget {
  final String title;
  final IconData type;
  final String data;

  const EditYear({Key? key, required this.title, required this.type, required this.data}) : super(key: key);

  @override
  State<EditYear> createState() => EditYearState();
}

class EditYearState extends State<EditYear> {
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

            SizedBox(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Choose year", style: GoogleFonts.poppins(),),
                        content: Container(
                          height: 200,
                          child: CupertinoPicker.builder(
                            itemExtent: 30,
                            scrollController: FixedExtentScrollController(initialItem: 0), 
                            onSelectedItemChanged: (index) {
                            },
                            itemBuilder: (context, index) {
                              return Text('${index+1}', style: GoogleFonts.poppins());
                            },
                            childCount: 5,
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Column(
                  children: [
                    SizedBox(height: 50,),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 25),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color.fromARGB(255, 215, 215, 215)),
                        borderRadius: BorderRadius.circular(10)
                    
                      ),
                      child: Center(child: Text(widget.data, style: GoogleFonts.poppins(fontSize: 20),),),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

