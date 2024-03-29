// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressTracker extends StatelessWidget {
  final double value;

  const ProgressTracker({Key? key, required this.value}) : super(key: key);

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


Widget HeightContainer(BuildContext context){
  return Container(
    alignment: Alignment.topCenter,
    child: Column(
      children: [
        SizedBox(height: 50,),
        Container(
          child: Column(
            children: [
              Transform.rotate(angle: -0.8 ,child: Icon(Icons.straighten_rounded, size: 50,)),
              SizedBox(height: 20,),
              Text("What is your height?", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 20),),
              SizedBox(height: 80,),
              SizedBox(
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Your height", style: GoogleFonts.poppins(),),
                          content: Container(
                            height: 200,
                            child: CupertinoPicker.builder(
                              itemExtent: 30,
                              scrollController: FixedExtentScrollController(initialItem: 20), 
                              onSelectedItemChanged: (index) {
                              },
                              itemBuilder: (context, index) {
                                return Text('${150 + index} cm', style: GoogleFonts.poppins());
                              },
                              childCount: 220 - 150,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color.fromARGB(255, 233, 233, 233))
                    ),
                    child: Center(child: Text("181 cm", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),),),
                  ),
                )
              ),
              SizedBox(height: 20,),
              Text("Skip", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),)
            ],
          ),
        )
      ],
    ),
  );
}

Widget DrinkingContainer(BuildContext context){
  return Container(
    alignment: Alignment.topCenter,
    child: Column(
      children: [
        SizedBox(height: 50,),
        Container(
          child: Column(
            children: [
              Icon(Icons.wine_bar_rounded, size: 50,),
              SizedBox(height: 20,),
              Text("Do you drink?", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 20),),
              SizedBox(height: 40,),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch, 
                        children: [
                          OptionChildrenBuilder("Frequently"),
                          SizedBox(height: 10,),
                          OptionChildrenBuilder("Socially"),
                          SizedBox(height: 10,),
                          OptionChildrenBuilder("Rarely"),
                          SizedBox(height: 10,),
                          OptionChildrenBuilder("Never"),
                          SizedBox(height: 10,),
                          OptionChildrenBuilder("Sober"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
  
              SizedBox(height: 30,),
              Text("Skip", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),)
            ],
          ),
        )
      ],
    ),
  );
}

Widget SmokingContainer(BuildContext context){
  return Container(
    alignment: Alignment.topCenter,
    child: Column(
      children: [
        SizedBox(height: 50,),
        Container(
          child: Column(
            children: [
              Icon(Icons.smoking_rooms_rounded, size: 50,),
              SizedBox(height: 20,),
              Text("Do you smoke?", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 20),),
              SizedBox(height: 40,),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch, 
                        children: [
                          OptionChildrenBuilder("Socially"),
                          SizedBox(height: 10,),
                          OptionChildrenBuilder("Regularly"),
                          SizedBox(height: 10,),
                          OptionChildrenBuilder("Never"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30,),
              Text("Skip", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),)
            ],
          ),
        )
      ],
    ),
  );
}

Widget LookingForContainer(BuildContext context){
  return Container(
    alignment: Alignment.topCenter,
    child: Column(
      children: [
        SizedBox(height: 50,),
        Container(
          child: Column(
            children: [
              Icon(Icons.search_rounded, size: 50,),
              SizedBox(height: 20,),
              Text("What do you want from your dates?", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 20), textAlign: TextAlign.center,),
              SizedBox(height: 40,),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch, 
                        children: [
                          OptionChildrenBuilder("Relationship"),
                          SizedBox(height: 10,),
                          OptionChildrenBuilder("Something Casual"),
                          SizedBox(height: 10,),
                          OptionChildrenBuilder("Don't know yet"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30,),
              Text("Skip", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),)
            ],
          ),
        )
      ],
    ),
  );
}

Widget ReligionContainer(BuildContext context) {
  return SingleChildScrollView(
    child: Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(height: 50,),
          Container(
            child: Column(
              children: [
                Icon(Icons.synagogue_rounded, size: 50,),
                SizedBox(height: 20,),
                Text("Do you identify with a religion?",textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 20),),
                SizedBox(height: 40,),
                Container(
                  height: MediaQuery.of(context).size.height * 0.6, // Adjust the height as needed
                  child: ListView(
                    children: [
                      OptionChildrenBuilder("Agnostic"),
                      SizedBox(height: 10,),
                      OptionChildrenBuilder("Atheist"),
                      SizedBox(height: 10,),
                      OptionChildrenBuilder("Buddhist"),
                      SizedBox(height: 10,),
                      OptionChildrenBuilder("Catholic"),
                      SizedBox(height: 10,),
                      OptionChildrenBuilder("Christian"),
                      SizedBox(height: 10,),
                      OptionChildrenBuilder("Hindu"),
                      SizedBox(height: 10,),
                      OptionChildrenBuilder("Jain"),
                      SizedBox(height: 10,),
                      OptionChildrenBuilder("Jewish"),
                      SizedBox(height: 10,),
                      OptionChildrenBuilder("Mormon"),
                      SizedBox(height: 10,),
                      OptionChildrenBuilder("Muslim"),
                      SizedBox(height: 10,),
                      OptionChildrenBuilder("Sikh"),
                      SizedBox(height: 10,),
                      OptionChildrenBuilder("Other"),
                      SizedBox(height: 30,),
                      Center(child: Text("Skip", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),))
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



Widget OptionChildrenBuilder(String optionText){
  return Container(
    padding: EdgeInsets.symmetric(vertical: 15),
    decoration: BoxDecoration(
      border: Border.all(color: Color.fromARGB(255, 233, 233, 233)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
      child: Text(
        optionText,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w400),
      ),
    ),
  );
}