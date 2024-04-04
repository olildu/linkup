// ignore_for_file: unused_element, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:demo/elements/candidate_page_elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color tagColor = Color(0xFF0C192C);

class ProfileImageFullscreen extends StatelessWidget {
  final String imagePath;

  const ProfileImageFullscreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 200.0),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  image: AssetImage(imagePath),
                )
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CandidateDetailsContainer extends StatelessWidget {
  final ScrollController scrollController;

  const CandidateDetailsContainer({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Container(
        color: Color(0xFF193046),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Candidate First Image
            buildProfileImage(context),

            // Candidate About Me and Tags
            aboutMeAndTags(),

            // Remaining Candidate Images
            nextImages(context),

            // From Candidate Details or Stream Detail
            fromOrStreamDetails(),
          ],
        ),
      ),
    );
  }
}
