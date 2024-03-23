// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const Create_User_MetaData());
}


class Create_User_MetaData extends StatelessWidget {
  const Create_User_MetaData({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(12, 25, 44, 1.0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              padding: EdgeInsets.all(10),
              width: 460,
              height: 366,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.person,
                    color: Color.fromRGBO(248, 197, 55, 1.0),
                    size: 80,
                  ),
                  SizedBox(height: 20,),
                  Text(
                    "What do you want people to call you?",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 40,),
                  Center(
                    child: SizedBox(
                      width: 280.0,
                      child: TextField(

                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                          hintText: 'Enter your name',
                          filled: true,
                          fillColor: Color.fromRGBO(217, 217, 217, 1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0), 
                            borderSide: BorderSide.none
                          ),
                        ),
                      ),
                    )
                  ),
                  SizedBox(height: 60,),

                  Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(248, 197, 55, 1.0),
                      borderRadius: BorderRadius.circular(50)
                    ),
                    child: Center(
                      child: Text(
                        "Next"
                      ),
                    ),
                  )

                ],
              ),
            ),
          ) 
        ,),

      ),
    );
  }
}
