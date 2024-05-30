// ignore_for_file: use_super_parameters, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:demo/colors/colors.dart';
import 'package:demo/api/api_calls.dart';
import 'package:demo/elements/profile_elements/elements.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  dynamic Userdata;
  bool isDataLoaded = true;
  bool aboutMeClicked = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    if (!isDataLoaded) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: 
      SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photos Title
                titleAndSubtitle("Your Photos", "Add photos that show your true self", subTitleColor: Theme.of(context).colorScheme.secondaryContainer),
                
                SizedBox(height: 30), 

                // Photos
                PhotosWidget(imageData: userValues.userImageData),

                SizedBox(height: 40), 

                // About Me Title
                titleAndSubtitle("About Me", "Write something that catches the eye", subTitleColor: Theme.of(context).colorScheme.secondaryContainer),

                SizedBox(height: 30), 

                // About Me Container

                aboutMeContainer(
                  initialValue: userValues.userData["aboutMe"] ?? "",
                  onPressed: () {
                    setState(() {
                      aboutMeClicked = true;
                    });
                  },
                  onFocusLost: () {
                    setState(() {
                      aboutMeClicked = false;
                    });
                  }
                ),

                if (aboutMeClicked)
                Column(
                  children: [
                    SizedBox(height: 20,),
                    Align(
                    alignment: Alignment.centerRight,
                    child: FloatingActionButton(onPressed: (){
                      setState(() {
                        aboutMeClicked = false;
                      });
                      Map userDataTags = {
                        "uid": userValues.uid,
                        'type': 'uploadTagData',
                        'key': userValues.cookieValue,
                        'keyToUpdate': "aboutMe",
                        'value': controller.text
                      };
                      ApiCalls.uploadUserTagData(userDataTags);
                    },
                    backgroundColor: reuseableColors.accentColor,
                    shape: const CircleBorder(),
                    child: ClipOval(child: Icon(Icons.done_rounded, color: Colors.white,)),),),
                  ],
                ),



                SizedBox(height: 20), 

                // More About Me Title
                titleAndSubtitle("More about me", "Things most people are curious about", subTitleColor: Theme.of(context).colorScheme.secondaryContainer),

                SizedBox(height: 30), 

                // More About Me Children
                moreAboutMeChildren(context, userValues.userData),

                SizedBox(height: 40), 

                // My Basics Title
                titleAndSubtitle("My basics", "Get your basics right", subTitleColor: Theme.of(context).colorScheme.secondaryContainer),

                SizedBox(height: 30), 

                //My Basics Chilren

                myBasicsChildren(context, userValues.userData)

              ],
            ),
          ),
        ),
      ),


    );
  }
}