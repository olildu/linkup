// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class settings extends StatelessWidget {
  const settings({Key? key});

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
      body: Center(
        child: Text(
          "This is the settings page",
          style: GoogleFonts.poppins(
            fontSize: 20
          ),
        ),
      ),
    );
  }
}
