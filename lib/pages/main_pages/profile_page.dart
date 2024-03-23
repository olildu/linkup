// ignore_for_file: use_super_parameters, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:demo/elements/profile_elements/elements.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: 
      // Initialize Widget going down
      SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photos Title
                titleAndSubtitle("Your Photos", "Add photos that show your true self"),
                
                SizedBox(height: 30), 
             
                // Photos
                photos(),

                SizedBox(height: 40), 

                // About Me Title
                titleAndSubtitle("About Me", "Write something that catches the eye"),

                SizedBox(height: 30), 

                // About Me Container

                aboutMeContainer(),

                SizedBox(height: 40), 

                // More About Me Title
                titleAndSubtitle("More about me", "Things most people are curious about"),

                SizedBox(height: 30), 

                // More About Me Children
                moreAboutMeChildren(context),

                SizedBox(height: 40), 

                // My Basics Title
                titleAndSubtitle("My basics", "Get your basics right"),

                SizedBox(height: 30), 

                //My Basics Chilren

                myBasicsChildren(context)

              ],
            ),
          ),
        ),
      ),


    );
  }
}