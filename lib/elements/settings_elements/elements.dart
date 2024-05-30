import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buttonBuilder(String title, IconData? iconData, BuildContext context){
  return Row(
    children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Theme.of(context).colorScheme.secondary,),
            color: Theme.of(context).colorScheme.primary
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

Widget DisableNotificationsButton(bool isSwitchOn, VoidCallback onPressed, BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Theme.of(context).colorScheme.secondary,),
              color: Theme.of(context).colorScheme.primary),
          child: Row(
            children: [
              Text(
                "Switch to light mode",
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

