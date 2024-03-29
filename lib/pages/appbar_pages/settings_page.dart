// ignore_for_file: prefer_const_constructors

import 'package:demo/elements/settings_elements/elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isSwitchOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true, // Centering the title text
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Snooze Box
            Container(
              child: Column(
                children: [
                  buttonBuilder("Snooze", null),
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

            SizedBox(height: 40,),

            // Disable Notification's Box

            Container(
              child: Column(
                children: [
                  DisableNotificationsButton(isSwitchOn, () {
                    setState(() {
                      isSwitchOn = !isSwitchOn;
                    });
                  }),
                  SizedBox(height: 15,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "Permanently disable all notifications received from MUJ Dating",
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40,),

            // Contact & FAQ Button
            buttonBuilder("Contact & FAQ", Icons.arrow_forward_ios_rounded),

            SizedBox(height: 10,),
            // Security and Privacy Button
            buttonBuilder("Security & Privacy", Icons.arrow_forward_ios_rounded),

            SizedBox(height: 60,),

            // Log Out Button
            buttonBuilder("Log Out", Icons.arrow_forward_ios_rounded),

            SizedBox(height: 10,),

            // Delete account Button
            buttonBuilder("Delete Account", Icons.arrow_forward_ios_rounded),


          ],
        ),
      ),
    );
  }
}
