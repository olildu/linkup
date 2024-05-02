// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:demo/Colors.dart';
import 'package:demo/pages/appbar_pages/filters_page.dart';
import 'package:demo/pages/main_pages/candidate_page.dart';
import 'package:demo/pages/main_pages/chat_page.dart';
import 'package:demo/pages/main_pages/profile_page.dart';
import 'package:demo/pages/appbar_pages/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:demo/api/api_calls.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import "dart:async";

class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  State<mainPage> createState() => mainPageState();
}

class mainPageState extends State<mainPage> {
  late int bottomBarIndex = 2;
  String appBarTitle = "MUJDating";
  IconData? type = Icons.tune_rounded;

  IconData profileIcon = Icons.person_outline_outlined;
  IconData candidateIcon = Icons.favorite_rounded;
  IconData chatIcon = Icons.chat_bubble_outline_rounded;

  late StreamSubscription networkChecker;
  late bool internetStatus = true;

  final List<Widget> _pages = [
    ProfilePage(),
    CandidatePage(),
    ChatPage(),
  ];

  void navigateActionButtons(BuildContext context) {
    switch (bottomBarIndex) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Settings()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Filter()),
        );
        break;
    }
  }

  void navigateBottomBar(int index) {
    HapticFeedback.vibrate(); 
    setState(() {
      bottomBarIndex = index;

      /* This function will track the user when he changes the page, when changed from match page gets the 
        userValues.userVisited and loops and removes n number of 0th elements from the list */

      if (bottomBarIndex != 1){
        for (int x = 0; x < userValues.userVisited; x++){
          userValues.matchUserDetails.removeAt(0);
          userValues.userImageURLs.removeAt(0);
        }
        userValues.userVisited = 0;
      }

      switch (bottomBarIndex) {
        case 0:
          appBarTitle = "Profile";
          type = Icons.settings_rounded;
          profileIcon = Icons.person_rounded;
          candidateIcon = Icons.favorite_outline_rounded;
          chatIcon = Icons.chat_bubble_outline_rounded;
          break;
        case 1:
          appBarTitle = "MUJDating";
          type = Icons.tune_rounded;
          candidateIcon = Icons.favorite_rounded;
          profileIcon = Icons.person_outline_outlined;
          chatIcon = Icons.chat_bubble_outline_rounded;
          break;
        case 2:
          appBarTitle = "";
          type = null;
          chatIcon = Icons.chat_bubble_rounded;
          profileIcon = Icons.person_outline_outlined;
          candidateIcon = Icons.favorite_outline_rounded;
          break;
      }
    });
  }

  void internetChecker(event){
    if(event == InternetConnectionStatus.connected){
      setState(() {
        internetStatus = true;
      });
    }
    if(event == InternetConnectionStatus.disconnected ){
      setState(() {
        internetStatus = false;
      });
    }
  }

  @override
  void initState(){
    super.initState();
    /* This is to make sure there is proper internet connection and this will get triggered on every page change */
    networkChecker = InternetConnectionChecker().onStatusChange.listen((event) {
      internetChecker(event);
    });
  }
  
  Widget buildNoInternetWidget() {
    return Container(
      padding: EdgeInsets.all(0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3), 
                ),
              ],
              color: reuseableColors.primaryColor, 
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'You are offline',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[bottomBarIndex],
      appBar: AppBar(
        toolbarHeight: 50,
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Stack(
          children: [
            Center(
              child: Text(
                appBarTitle,
                style: GoogleFonts.poppins(),
              ),
            ),
            if (!internetStatus) buildNoInternetWidget().animate(delay: Duration(milliseconds: 500)).slideY(begin: -1.8),

            if (internetStatus)  buildNoInternetWidget().animate().slideY(end: -1.8).fadeOut(),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              navigateActionButtons(context);
            },
            child: Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(type),
            ),
          ),
        ],
      ),
      drawer: FractionallySizedBox(
        widthFactor: 0.75,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text("LOGO", style: GoogleFonts.poppins(fontSize: 40))),
              SizedBox(height: 70),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Settings(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Icon(Icons.settings_rounded),
                      SizedBox(width: 20),
                      Text("Settings", style: GoogleFonts.poppins(fontSize: 20)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded),
                      SizedBox(width: 20),
                      Text("Log Out", style: GoogleFonts.poppins(fontSize: 20)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: const Color.fromARGB(255, 215, 215, 215),
                width: 1.0,
              )
            )
          ),
          child: GNav(
            onTabChange: (value) => {navigateBottomBar(value)},
            selectedIndex: 1,
            tabs: [
              GButton(icon: profileIcon, ),
              GButton(icon: candidateIcon, ),
              GButton(icon: chatIcon,),
            ],
          ),
        ),
      ),
    );
  }
}
