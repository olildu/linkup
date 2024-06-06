// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:linkup/colors/colors.dart';
import 'package:linkup/pages/appbar_pages/filters_page.dart';
import 'package:linkup/pages/main_pages/candidate_page.dart';
import 'package:linkup/pages/main_pages/chat_page.dart';
import 'package:linkup/pages/main_pages/profile_page.dart';
import 'package:linkup/pages/appbar_pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkup/api/common_functions.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import "dart:async";
import 'package:linkup/pages/notification_page/notification.dart';

class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  State<mainPage> createState() => mainPageState();
}

class mainPageState extends State<mainPage> {
  late int bottomBarIndex = 1;
  String appBarTitle = "linkup";
  IconData? type = Icons.tune_rounded;

  IconData profileIcon = Icons.person_outline_outlined;
  IconData candidateIcon = Icons.favorite_rounded;
  IconData chatIcon = Icons.chat_bubble_outline_rounded;

  late StreamSubscription networkChecker;
  late bool internetStatus = true;

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

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

      commonFunction().manageNotificationHandlers(index); // Function to keep notificationHandler updated

      /* This function will track the user when he changes the page, when changed from match page gets the 
        userValues.userVisited and loops and removes n number of 0th elements from the list */
      commonFunction().manageUserVisited(bottomBarIndex);

      switch (bottomBarIndex) {
        case 0:
          appBarTitle = "Profile";
          type = Icons.settings_rounded;
          profileIcon = Icons.person_rounded;
          candidateIcon = Icons.favorite_outline_rounded;
          chatIcon = Icons.chat_bubble_outline_rounded;
          break;
        case 1:
          appBarTitle = "linkup";
          type = Icons.tune_rounded;
          candidateIcon = Icons.favorite_rounded;
          profileIcon = Icons.person_outline_outlined;
          chatIcon = Icons.chat_bubble_outline_rounded;
          break;
        case 2:
          appBarTitle = "Chats";
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

    // Init notification listeners
    notificationHandlers().setupFirebaseMessaging(context);

    //
    analytics.setAnalyticsCollectionEnabled(true);
  }
  
  Widget buildNoInternetWidget(String width) {
    double offsetMiddle = (115 / 392.72727272727275) * MediaQuery.of(context).size.width;
    return Transform.translate(
      offset: Offset(offsetMiddle,0),
      child: Container(
        padding: EdgeInsets.all(0),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
        ),
        child: Row(
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
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.background
      ),
      child: Scaffold(
        body: _pages[bottomBarIndex],
        appBar: AppBar(
          toolbarHeight: 50,
          scrolledUnderElevation: 0,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  appBarTitle,
                  style: GoogleFonts.raleway(fontSize: 25, fontWeight: FontWeight.w500),
                ),
              ),
              if (!internetStatus) buildNoInternetWidget((MediaQuery.of(context).size.width).toString()).animate(delay: Duration(milliseconds: 500)).slideY(begin: -1.8),
      
              if (internetStatus)  buildNoInternetWidget((MediaQuery.of(context).size.width).toString()).animate().slideY(end: -1.8).fadeOut(),
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
      
        bottomNavigationBar: SizedBox(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
            ),
            child: Transform.translate(
              offset: Offset(0,10),
              child: GNav(
                onTabChange: (value) async{
                  navigateBottomBar(value);
                  
                  // Testing analytics here
                  await analytics.logEvent(
                    name: "pages_tracked",
                    parameters: {
                      "page_name" : appBarTitle,
                      "page_index" : value
                    }
                  );
                },
                selectedIndex: 1,
                tabs: [
                  GButton(icon: profileIcon, ),
                  GButton(icon: candidateIcon, ),
                  GButton(icon: chatIcon,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

