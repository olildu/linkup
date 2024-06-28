import 'package:glass/glass.dart';
import 'package:linkup/elements/candidate_details_elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linkup/ImageHashing/decode.dart';
import 'package:octo_image/octo_image.dart';

Widget buildProfileImage(BuildContext context, Map candidateDetails, String imageUrl, String imageHash, double imageHeight, double maxWidth) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileImageFullscreen(imagePath: imageUrl),
        ),
      );
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          ClipRRect( // If the size of screen gets too small then this widget clips the rest of the part away
            child: SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: OctoImage(
                image: CachedNetworkImageProvider(imageUrl),
                placeholderBuilder: OctoBlurHashFix.placeHolder(imageHash, 100),
                fit: BoxFit.cover,
              )
            ),
          ),
          Positioned(
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: maxWidth - 20,
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8), // Adding some transparency
                  padding: const EdgeInsets.all(10.0), // Adding some padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${candidateDetails["UserDetails"]["name"]}, ${candidateDetails["UserDetails"]["age"]}',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ), 
                          
                          const SizedBox(width: 10,),

                          Container(
                            width: 106,
                            height: 30,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 0, 173, 170),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_rounded, size: 18, color: Colors.white,),
                                const SizedBox(width: 5,),
                                Text(
                                  "Verified", 
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),

                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.school_outlined, color: Theme.of(context).shadowColor,),
                          const SizedBox(width: 5),
                          Text(
                            'Doing ${candidateDetails["UserDetails"]["stream"]}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Theme.of(context).shadowColor,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).asGlass(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget nextImages(BuildContext context, Map candidateDetails, double imageHeight, String imageName, String imageHash) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Align(
        alignment: Alignment.topLeft,
        child: GestureDetector(
          child: SizedBox(
            height: imageHeight,
            width: double.infinity,
            child: OctoImage(
                image: CachedNetworkImageProvider(imageName),
                placeholderBuilder: OctoBlurHashFix.placeHolder(imageHash, 100),
                fit: BoxFit.cover,
              )
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileImageFullscreen(imagePath: imageName),
              ),
            );
          },
        ),
      ),
    ),
  );
}


Widget buildTag(String text, IconData iconData, BuildContext context) {
  return IntrinsicWidth(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          Icon(iconData, size: 20),
          const SizedBox(width: 5),
          Text(text, style: GoogleFonts.poppins()),
        ],
      ),
    ),
  );
}

Widget candidateTags(BuildContext context, {Map? data, Map? candidateDetails}) {
  String? drinkingStatus;
  String? smokingStatus;
  String? height;
  String? religionStatus;
  String? gender;
  String? lookingFor;

  // Extract relevant data from the provided map
  if (data != null) {
    drinkingStatus = data['drinkingStatus'];
    smokingStatus = data['smokingStatus'];
    height = data['height'];
    religionStatus = data['religionStatus'];
    lookingFor = data['lookingFor'];
    gender = data["gender"];
  } else if (candidateDetails != null) {
    drinkingStatus = candidateDetails['drinkingStatus'];
    smokingStatus = candidateDetails['smokingStatus'];
    height = candidateDetails['height'];
    religionStatus = candidateDetails['religionStatus'];
    lookingFor = candidateDetails['lookingFor'];
    gender = candidateDetails["gender"];
  }

  return Wrap(
    alignment: WrapAlignment.start,
    runSpacing: 5,
    children: [
      if (gender != null) IntrinsicWidth(child: buildTag(gender, Icons.person_rounded, context)),
      const SizedBox(width: 7),
      if (height != null) IntrinsicWidth(child: buildTag(height, Icons.straighten_rounded, context)),
      const SizedBox(width: 7),
      if (drinkingStatus != null) IntrinsicWidth(child: buildTag(drinkingStatus, Icons.wine_bar_rounded, context)),
      const SizedBox(width: 7),
      if (smokingStatus != null) IntrinsicWidth(child: buildTag(smokingStatus, Icons.smoking_rooms_rounded, context)),
      const SizedBox(width: 7),
      if (religionStatus != null) IntrinsicWidth(child: buildTag(religionStatus, Icons.synagogue_rounded, context)),
      const SizedBox(width: 7),
      if (lookingFor != null) IntrinsicWidth(child: buildTag(lookingFor, Icons.search_rounded, context)),
    ],
  );
}

// Helper function to build a tag
Widget aboutMeAndTags(BuildContext context, {Map? data, Map? candidateDetails}) {
  String? aboutMe = candidateDetails?["aboutMe"] ?? data?["aboutMe"];
  String? name = candidateDetails?["name"] ?? data?["name"];

  return Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          child: Column(
            children: [
              const Icon(Icons.keyboard_arrow_down_rounded, size: 40),
              if (aboutMe != null) ...[
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "About Me",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    aboutMe,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
              ],
              Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '$name\'s info',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topLeft,
                    child: candidateTags(data: data, candidateDetails: candidateDetails, context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
Widget fromOrStreamDetails({bool buttonsNeeded = true, Map? candidateDetails}) {
  String fromOrStreamString;
  if (candidateDetails?["fromPlace"] == null){
    fromOrStreamString = '${candidateDetails?["stream"]}, ${addYearSuffix((candidateDetails?["year"]).toString())} year';
  }
  else{
    fromOrStreamString = '${candidateDetails?["fromPlace"]}';
  }
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      children: [
        // Candidate Name
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            candidateDetails?["fromPlace"] == null ? "${candidateDetails?["name"]} is doing" : "📍 ${candidateDetails?["name"]} is from ",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500 
            ),
          ),
        ),

        const SizedBox(height: 5),
        
        // Candidate HomeTown
        SizedBox(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  fromOrStreamString,
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.w600
                  ),
                ),
              )
            ],
          ),
        ),
        
        if (buttonsNeeded)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30,),

              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(30), 
                child: const Icon(Icons.close_rounded, color: Colors.black, size: 40),
              ),
              const SizedBox(width: 20,),
              Container(
                decoration: const BoxDecoration(
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

  if (yearString.isEmpty) {
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