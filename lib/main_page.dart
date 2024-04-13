// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:demo/pages/appbar_pages/filters_page.dart';
import 'package:demo/pages/main_pages/candidate_page.dart';
import 'package:demo/pages/main_pages/chat_page.dart';
import 'package:demo/pages/main_pages/profile_page.dart';
import 'package:demo/pages/appbar_pages/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class mainPage extends StatefulWidget {
  const mainPage({Key? key}) : super(key: key);

  @override
  State<mainPage> createState() => mainPageState();
}

class mainPageState extends State<mainPage> {
  late int bottomBarIndex = 0;
  String appBarTitle = "MUJDating";
  IconData? type = Icons.tune_rounded;

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
    setState(() {
      bottomBarIndex = index;
      switch (bottomBarIndex) {
        case 0:
          appBarTitle = "Profile";
          type = Icons.settings_rounded;
          break;
        case 1:
          appBarTitle = "MUJDating";
          type = Icons.tune_rounded;
          break;
        case 2:
          appBarTitle = "";
          type = null;
          break;
      }
    });
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
        title: Center(
          child: Text(
            appBarTitle,
            style: GoogleFonts.poppins(),
          ),
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
      bottomNavigationBar: Container(
        color: Colors.white,
        child: GNav(
          onTabChange: (value) => {navigateBottomBar(value)},
          gap: 8,
          selectedIndex: 1,
          tabs: [
            GButton(icon: Icons.person_rounded, text: "Profile"),
            GButton(icon: Icons.favorite_border, text: "Favourite"),
            GButton(icon: Icons.chat_bubble_outline_rounded, text: "Chat"),
          ],
        ),
      ),
    );
  }
}
