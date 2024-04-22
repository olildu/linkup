import 'package:demo/api/api_calls.dart';
import 'package:demo/elements/candidate_details_elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget buildProfileImage(BuildContext context, Map candidateDetails, String imageUrl, double imageHeight) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileImageFullscreen(imagePath: imageUrl),
        ),
      );
    },
    child: Align(
      alignment: Alignment.topLeft,
      child: Stack(
        children: [
          SizedBox(
            height: 665,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => Center(child: CircularProgressIndicator()), // Placeholder widget while image is loading
                    // errorWidget: (context, url, error) => Text((Key.currentContext?.size?.height).toString()), // Widget to display in case of error loading image
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${candidateDetails["UserDetails"]["name"]}, ${candidateDetails["UserDetails"]["age"]}',
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
                      'Doing ${candidateDetails["UserDetails"]["stream"]}',
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
  );
}

Widget nextImages(BuildContext context, Map candidateDetails, double imageHeight, {String? secondImageURL, String? thirdImageURL}) {
  String imageName = secondImageURL != null ? secondImageURL : thirdImageURL ?? ""; // Use filteredList if not null, otherwise use nextImageName
  return Align(
    alignment: Alignment.topLeft,
    child: Stack(
      children: [
        GestureDetector(
          child: SizedBox(
            height: 665,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: imageName,
                    placeholder: (context, url) => Center(child: CircularProgressIndicator()), // Placeholder widget while image is loading
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover, // Widget to display in case of error loading image
                  ),
                ),
              ],
            ),
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
      ],
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

Widget candidateTags({Map? data, Map? candidateDetails}) {
  String? drinkingStatus;
  String? smokingStatus;
  String? height;
  String? religionStatus;
  String? lookingFor;

  // Extract relevant data from the provided map
  if (data != null) {
    drinkingStatus = data['drinkingStatus'];
    smokingStatus = data['smokingStatus'];
    height = data['height'];
    religionStatus = data['religionStatus'];
    lookingFor = data['lookingFor'];
  } else if (candidateDetails != null) {
    drinkingStatus = candidateDetails['drinkingStatus'];
    smokingStatus = candidateDetails['smokingStatus'];
    height = candidateDetails['height'];
    religionStatus = candidateDetails['religionStatus'];
    lookingFor = candidateDetails['lookingFor'];
  }

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

Widget aboutMeAndTags({Map? data, Map? candidateDetails}) {
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
                      candidateDetails?["aboutMe"] ?? "Check",
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
                        child: candidateTags(data: data, candidateDetails: candidateDetails),
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

Widget fromOrStreamDetails({bool buttonsNeeded = true, Map? data, Map? candidateDetails}) {
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