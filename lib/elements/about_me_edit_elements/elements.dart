import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget ProgressTracker(){
    return Container(
      height: 5,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            color: Colors.yellow,
          ),
        ],
      ),
    );
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
                              scrollController: FixedExtentScrollController(initialItem: 20), // Add scrollController
                              onSelectedItemChanged: (index) {
                                // Handle selected item change
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