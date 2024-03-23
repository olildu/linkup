// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:demo/pages/basics_edit_page/edit_stream_page.dart';
import 'package:demo/pages/filters_page.dart';
import 'package:demo/pages/main_pages/candidate_page.dart';
import 'package:demo/pages/main_pages/chat_page.dart';
import 'package:demo/pages/main_pages/profile_page.dart';
import 'package:demo/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  int bottomBarIndex = 1;
  String appBarTitle = "Profile";
  IconData? type = Icons.tune_rounded;

  void navigateActionButtons(BuildContext context) {

    switch (bottomBarIndex){
      
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => settings()),
        );
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Filter()),
        );
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
          appBarTitle = "";
          type = Icons.tune_rounded;
          break;

        case 2:
          appBarTitle = "";
          // type = null;
          break;
      }
    });
  }

  final List<Widget> _pages = [
    ProfilePage(),
    CandidatePage(),
    ChatPage(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[bottomBarIndex],
      appBar: AppBar(
        toolbarHeight: 50,
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Icon(Icons.menu),
        title: Center(
          child: Text(
            appBarTitle,
            style: GoogleFonts.poppins(
            ),
          )
          ),
        actions: [
          GestureDetector(
            onTap: (){
              navigateActionButtons(context);
            },
            child: Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(type),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: GNav(
          onTabChange:(value) => {
            navigateBottomBar(value)
          },
          gap: 8,
          selectedIndex: 1,
          tabs: [
            GButton(icon: Icons.person_rounded, text: "Profile",),
            GButton(icon: Icons.favorite_border, text: "Favourite",),
            GButton(icon: Icons.chat_bubble_outline_rounded, text: "Chat",),
          ],),
      ),
    );
  }
}