// ignore_for_file: unused_element, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

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
          child: new Center(
            child: new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  fit: BoxFit.fitWidth,
                  image: new AssetImage(imagePath),
                )
              ),
            ),
          ),
        ),
      ),
    );
  }
}



Widget buildProfileImage(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileImageFullscreen(imagePath: 'lib/images/me3.jpg'),
        ),
      );
    },
    child: Align(
      alignment: Alignment.topLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: Stack(
          children: [
            Image.asset('lib/images/me3.jpg'),
            Positioned(
              bottom: 20,
              left: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ebin, 18',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.school_outlined, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        'Doing B.Tech',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget nextImages(BuildContext context) {
  return Align(
    alignment: Alignment.topLeft,
    child: ClipRRect(
      child: Stack(
        children: [
          GestureDetector(
            child: Image.asset('lib/images/me2.jpg'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileImageFullscreen(imagePath: 'lib/images/me2.jpg'),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

Widget buildTag(String text, IconData iconData) {
  return IntrinsicWidth(
    child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: tagColor,
      ),
      child: Row(
        children: [
          Icon(iconData, color: Colors.white, size: 20),
          SizedBox(width: 5),
          Text(text, style: GoogleFonts.poppins(color: Colors.white)),
        ],
      ),
    ),
  );
}

Widget candidateTags() {
  return Wrap(
    alignment: WrapAlignment.start,
    runSpacing: 5,
    children: [
      IntrinsicWidth(child: buildTag("Causally", Icons.wine_bar_rounded)),
      SizedBox(width: 5),
      IntrinsicWidth(child: buildTag("Causally", Icons.smoking_rooms_rounded)),
      SizedBox(width: 5),
      IntrinsicWidth(child: buildTag("Something Casual", Icons.search_rounded)),
      SizedBox(width: 5),
      IntrinsicWidth(child: buildTag("180cm", Icons.straighten_rounded)),
    ],
  );
}

Widget aboutMeAndTags() {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Column(
      children: [
        SizedBox(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Transform.translate(
                    offset: Offset(6, 0),
                    child: Text(
                      "About Me",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 7),
                Align(
                  alignment: Alignment.topLeft,
                  child: Transform.translate(
                    offset: Offset(6, 0),
                    child: Text(
                      "This is my about me",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Container(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Transform.translate(
                          offset: Offset(6, 0),
                          child: Text(
                            "My Basics",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.topLeft,
                        child: candidateTags(),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget fromOrStreamDetails() {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      children: [
        // Candidate Name
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Ebin's from",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),

        SizedBox(height: 10),
        
        // Candidate HomeTown
        SizedBox(
          child: Container(
            child: Column(
              children: [
                Container(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Kerala",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),

        SizedBox(height: 30,),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(30), 
              child: Icon(Icons.close_rounded, color: Colors.black, size: 40),
            ),
            SizedBox(width: 20,),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, 
              ),
              padding: EdgeInsets.all(30),
              child: Icon(Icons.favorite_rounded, color: Color.fromARGB(255, 226, 47, 47), size: 40),
            ),
          ],
        )
      ],
    ),
  );
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
