// ignore_for_file: prefer_const_constructors

import 'package:linkup/colors/colors.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/elements/settings_elements/elements.dart';
import 'package:linkup/pages/login_page/login_page.dart';
import 'package:linkup/pages/providers/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextStyle avoidMaterial = GoogleFonts.poppins(
  color: Colors.white,
  fontSize: 20,
  fontWeight: FontWeight.normal,
  decoration: TextDecoration.none,
);


class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isSwitchOn = userValues.darkTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true, // Centering the title text
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Snooze Box
              GestureDetector(
                onTap: () {
                  showCupertinoModalPopup(context: context, builder: (BuildContext context) => 
                    SizedBox(
                      height: 200,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  userValues.snoozeEnabled ? "Turn off snooze mode and let your profile be seen?" : "Do you want to turn on snooze and become ghost?" ,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Yes container, when clicked enables snooze mode depending on wheter snooze is on or off
                                    GestureDetector(
                                      onTap: ()  {
                                        setState(() {
                                          userValues.snoozeEnabled = !userValues.snoozeEnabled; // Toggle the snoozeMode
                                        });
                                        if (userValues.snoozeEnabled) {
                                          ApiCalls.enableSnoozeMode();
                                        } else {
                                          ApiCalls.disableSnoozeMode();
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        width: 100,
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.circular(30)
                                        ),
                                        child: Center(child: Text("Yes", style: avoidMaterial,),),
                                      ),
                                    ),
                                    SizedBox(width: 20,),
                                    // No container, when clicked just closes the popup
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        width: 100,
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: reuseableColors.accentColor,
                                          borderRadius: BorderRadius.circular(30)
                                        ),
                                        child: Center(child: Text("No", style: avoidMaterial),),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  child: Column(
                    children: [
                      buttonBuilder(userValues.snoozeEnabled ? "Disable Snooze" : "Snooze", null, context),
                      SizedBox(height: 15,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          "Temporarily hide your profile. If you do this, you won’t lose any connections or chats.",
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        
              SizedBox(height: 40,),
        
              // Disable Notification's Box
              // Container(
              //   child: Column(
              //     children: [
              //       DisableNotificationsButton(isSwitchOn, () async{
              //         setState(() {
              //           isSwitchOn = !isSwitchOn;
              //           userValues.darkTheme = false;
              //         });
              //         Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              //         print(isSwitchOn);
                      
              //         SharedPreferences prefs = await SharedPreferences.getInstance();
              //         await prefs.setBool('darkTheme', isSwitchOn);
                      
              //       }, context),
              //       SizedBox(height: 15,),
              //       Padding(
              //         padding: EdgeInsets.symmetric(horizontal: 5),
              //         child: Text(
              //           "Switch to light mode or dark mode, Dark mode choosen as default",
              //           style: GoogleFonts.poppins(),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              GestureDetector(
                onTap: () async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                  await prefs.setBool('darkTheme', userValues.darkTheme);
                },
                child: Container(
                    child: Column(
                      children: [
                        buttonBuilder(userValues.darkTheme ? "Switch to light mode" : "Switch to dark mode", null, context),
                        SizedBox(height: 15,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Switch to light mode or dark mode, Dark mode choosen as default",
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
        
              SizedBox(height: 40,),
        
              // Contact & FAQ Button
              buttonBuilder("Contact & FAQ", Icons.arrow_forward_ios_rounded, context),
        
              SizedBox(height: 10,),
              // Security and Privacy Button
              buttonBuilder("Security & Privacy", Icons.arrow_forward_ios_rounded, context),
        
              SizedBox(height: 60,),
        
              // Log Out Button
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: buttonBuilder("Log Out", Icons.arrow_forward_ios_rounded, context)),
        
              SizedBox(height: 10,),
        
              // Delete account Button
              buttonBuilder("Delete Account", Icons.arrow_forward_ios_rounded, context),
        
        
            ],
          ),
        ),
      ),
    );
  }
}
