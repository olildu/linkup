import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buttonBuilder(String title, IconData? iconData){
  return Row(
    children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color(0xFFD9D9D9) 
          ),
          child: Row(
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 18),),
              Spacer(),
              Icon(iconData),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget DisableNotificationsButton(bool isSwitchOn, VoidCallback onPressed) {
  return Row(
    children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: const Color(0xFFD9D9D9)),
          child: Row(
            children: [
              Text(
                "Disable all notifications",
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              Spacer(),
              Switch(
                value: isSwitchOn,
                onChanged: (value) {
                  onPressed();
                },
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

