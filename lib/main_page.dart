import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/UI/pages/main_pages/candidate_page.dart';
import 'package:linkup/UI/pages/main_pages/chat_page.dart';
import 'package:linkup/UI/pages/main_pages/profile_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkup/api/common_functions.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:linkup/UI/pages/notification_page/notification.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  late int bottomBarIndex = 1;
  String appBarTitle = "linkup";
  IconData? type = Icons.tune_rounded;
  
  IconData profileIcon = Icons.person_outline_outlined;
  IconData candidateIcon = Icons.favorite_rounded;
  IconData chatIcon = Icons.chat_bubble_outline_rounded;

  late StreamSubscription networkChecker;
  late bool internetStatus = true;
  final NotificationHandlers _notificationHandlers = NotificationHandlers();

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final List<Widget> _pages = [
    const ProfilePage(),
    const CandidatePage(),
    const ChatPage(),
  ];


  @override
  void initState() {
    super.initState();
    /* This is to make sure there is proper internet connection and this will get triggered on every page change */
    networkChecker = InternetConnection().onStatusChange.listen((event) {
      internetChecker(event);
    });

    // Register callback for notifications
    _notificationHandlers.registerCallback(_onNotificationReceived);

    // Init notification listeners
    _notificationHandlers.setupFirebaseMessaging(context);

    //
    analytics.setAnalyticsCollectionEnabled(true);
  }

  @override
  void dispose() {
    networkChecker.cancel();
    super.dispose();
  }

  void navigateBottomBar(int index) {
    // HapticFeedback.vibrate(); 
    setState(() {
      bottomBarIndex = index;

      CommonFunction().manageNotificationHandlers(index); // Function to keep notificationHandler updated

      /* This function will track the user when he changes the page, when changed from match page gets the 
        UserValues.userVisited and loops and removes n number of 0th elements from the list */
      CommonFunction().manageUserVisited(bottomBarIndex);

      void checkChatIcon(){
        if (bottomBarIndex != 2){
          if (UserValues.notificationCount == 0){
            chatIcon = Icons.chat_bubble_outline_rounded;
          }
          else{
            chatIcon = Icons.mark_chat_unread_outlined;
          }
        }
        else{
          UserValues.notificationCount = 0;
          UserValues.usersNotificationCounter = [];
          
          chatIcon = Icons.chat_bubble_rounded;
        }

      }
      checkChatIcon();
      
      switch (bottomBarIndex) {
        case 0:
          appBarTitle = "Profile";
          type = Icons.settings_rounded;
          profileIcon = Icons.person_rounded;
          candidateIcon = Icons.favorite_outline_rounded;
          break;
        case 1:
          appBarTitle = "linkup";
          type = Icons.tune_rounded;
          candidateIcon = Icons.favorite_rounded;
          profileIcon = Icons.person_outline_outlined;
          break;
        case 2:
          appBarTitle = "Chats";
          type = null;
          profileIcon = Icons.person_outline_outlined;
          candidateIcon = Icons.favorite_outline_rounded;
          break;
      }
    });
  }

  void internetChecker(event) {
    if (event == InternetStatus.connected) {
      setState(() {
        internetStatus = true;
      });
    }
    if (event == InternetStatus .disconnected) {
      setState(() {
        internetStatus = false;
      });
    }
  }

  void _onNotificationReceived() {
    setState(() {
      chatIcon = Icons.mark_chat_unread_outlined;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.surface
      ),
      child: Scaffold(
        body: _pages[bottomBarIndex],
        appBar: AppBar(
          toolbarHeight: 50,
          scrolledUnderElevation: 0,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  appBarTitle,
                  style: GoogleFonts.raleway(fontSize: 25, fontWeight: FontWeight.w500),
                ),
              ),
              if (!internetStatus) buildNoInternetWidget(context, (MediaQuery.of(context).size.width).toString()).animate(delay: const Duration(milliseconds: 500)).slideY(begin: -1.8),
      
              if (internetStatus)  buildNoInternetWidget(context, (MediaQuery.of(context).size.width).toString()).animate().slideY(end: -1.8).fadeOut(),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () {
                CommonFunction().navigateActionButtons(context, bottomBarIndex);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Icon(type),
              ),
            ),
          ],
        ),
      
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Transform.translate(
            offset: const Offset(0,10),
            child: GNav(
              onTabChange: (value) async {
                navigateBottomBar(value);
                
                // Testing analytics here
                await analytics.logEvent(
                  name: "pages_tracked",
                  parameters: {
                    "page_name": appBarTitle,
                    "page_index": value
                  }
                );
              },
              selectedIndex: 1,
              tabs: [
                GButton(icon: profileIcon),
                GButton(icon: candidateIcon),
                GButton(icon: chatIcon),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
