// ignore_for_file: use_super_parameters, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:demo/Colors.dart';
import 'package:demo/api/api_calls.dart';
import 'package:demo/elements/profile_elements/elements.dart';
import 'package:demo/main_page.dart';
import 'package:demo/pages/login_page/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  dynamic Userdata;
  bool isDataLoaded = false;
  bool test = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }


  void fetchUserData() async{
    User? user = FirebaseAuth.instance.currentUser;
    final ref = FirebaseDatabase.instance.ref().child("/UsersMetaData/${user?.uid}/");
    
    ref.onValue.listen((event) {
      Userdata = event.snapshot.value;
      userValues.userData = Userdata["UserDetails"];
      setState(() {
        isDataLoaded = true;
      });
    },);
  }

  @override
  Widget build(BuildContext context) {
    if (!isDataLoaded) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
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
                titleAndSubtitle("Your Photos", "Add photos that show your true self"),
                
                SizedBox(height: 30), 

                // Photos
                PhotosWidget(imageData: Userdata["ImageDetails"]),

                SizedBox(height: 40), 

                // About Me Title
                titleAndSubtitle("About Me", "Write something that catches the eye"),

                SizedBox(height: 30), 

                // About Me Container

                aboutMeContainer(
                  initialValue: Userdata?["UserDetails"]["aboutMe"] ?? "",
                  onPressed: () {
                    setState(() {
                      test = true;
                    });
                  },
                  onFocusLost: () {
                    setState(() {
                      test = false;
                    });
                  }
                ),

                if (test)
                Column(
                  children: [
                    SizedBox(height: 20,),
                    Align(
                    alignment: Alignment.centerRight,
                    child: FloatingActionButton(onPressed: (){
                      setState(() {
                        test = false;
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
                titleAndSubtitle("More about me", "Things most people are curious about"),

                SizedBox(height: 30), 

                // More About Me Children
                moreAboutMeChildren(context, Userdata["UserDetails"]),

                SizedBox(height: 40), 

                // My Basics Title
                titleAndSubtitle("My basics", "Get your basics right"),

                SizedBox(height: 30), 

                //My Basics Chilren

                myBasicsChildren(context, Userdata["UserDetails"])

              ],
            ),
          ),
        ),
      ),


    );
  }
}