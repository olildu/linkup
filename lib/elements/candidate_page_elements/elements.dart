import 'package:demo/elements/candidate_details_elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildProfileImage(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileImageFullscreen(imagePath: 'lib/images/me3.jpg'),
        ),
      );
    },
    child: Align(
      alignment: Alignment.topLeft,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
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
                      const Icon(Icons.school_outlined, color: Colors.white),
                      const SizedBox(width: 5),
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
                  builder: (context) => const ProfileImageFullscreen(imagePath: 'lib/images/me2.jpg'),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: tagColor,
      ),
      child: Row(
        children: [
          Icon(iconData, color: Colors.white, size: 20),
          const SizedBox(width: 5),
          Text(text, style: GoogleFonts.poppins(color: Colors.white)),
        ],
      ),
    ),
  );
}

Widget candidateTags({Map? data}) {
  // Extract relevant data from the provided map
  String? drinkingStatus = data?['drinkingStatus'];
  String? smokingStatus = data?['smokingStatus'];
  String? height = data?['height'];
  String? religionStatus = data?['religionStatus'];
  String? lookingFor = data?['lookingFor'];

  return Wrap(
    alignment: WrapAlignment.start,
    runSpacing: 5,
    children: [
      if (height != null) IntrinsicWidth(child: buildTag(height, Icons.straighten_rounded)),
      const SizedBox(width: 5),
      if (drinkingStatus != null) IntrinsicWidth(child: buildTag(drinkingStatus, Icons.wine_bar_rounded)),
      const SizedBox(width: 5),
      if (smokingStatus != null) IntrinsicWidth(child: buildTag(smokingStatus, Icons.smoking_rooms_rounded)),
      const SizedBox(width: 5),
      if (religionStatus != null) IntrinsicWidth(child: buildTag(religionStatus, Icons.synagogue_rounded)),
      const SizedBox(width: 5),
      if (lookingFor != null) IntrinsicWidth(child: buildTag(lookingFor, Icons.search_rounded)),

    ],
  );
}

// Helper function to build a tag

Widget aboutMeAndTags({Map? data}) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Column(
      children: [
        SizedBox(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Transform.translate(
                    offset: const Offset(6, 0),
                    child: Text(
                      "About Me",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Align(
                  alignment: Alignment.topLeft,
                  child: Transform.translate(
                    offset: const Offset(6, 0),
                    child: Text(
                      data?["aboutMe"] ?? "Check",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Transform.translate(
                          offset: const Offset(6, 0),
                          child: Text(
                            "My Basics",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.topLeft,
                        child: candidateTags(data: data),
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

Widget fromOrStreamDetails({bool buttonsNeeded = true, Map? data}) {
  String fromOrStreamString;
  if (data?["fromPlace"] == null){
    fromOrStreamString = '${data?["stream"]}, ${addYearSuffix((data?["year"]).toString())} year';
  }
  else{
    fromOrStreamString = '${data?["fromPlace"]}';
  }
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      children: [
        // Candidate Name
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            data?["fromPlace"] == null ? "${data?["name"]} is doing" : "📍 ${data?["name"]} is from",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),

        const SizedBox(height: 10),
        
        // Candidate HomeTown
        SizedBox(
          child: Container(
            child: Column(
              children: [
                Container(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      fromOrStreamString,
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

        const SizedBox(height: 30,),
        
        if (buttonsNeeded)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(30), 
                child: const Icon(Icons.close_rounded, color: Colors.black, size: 40),
              ),
              const SizedBox(width: 20,),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, 
                ),
                padding: const EdgeInsets.all(30),
                child: const Icon(Icons.favorite_rounded, color: Color.fromARGB(255, 226, 47, 47), size: 40),
              ),
            ],
          ),
      ],
    ),
  );
}

String addYearSuffix(String yearString) {

  if (yearString == null || yearString.isEmpty) {
    return '';
  }
  
  int year = int.tryParse(yearString) ?? 0;
  String suffix = 'th';
  int lastDigit = year % 10;
  if (lastDigit == 1 && year != 11) {
    suffix = 'st';
  } else if (lastDigit == 2 && year != 12) {
    suffix = 'nd';
  } else if (lastDigit == 3 && year != 13) {
    suffix = 'rd';
  }
  return '$year$suffix';
}