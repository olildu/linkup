import 'dart:convert';

import 'package:demo/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:demo/elements/candidate_details_elements/elements.dart';
import 'package:demo/pages/match_banner_page/matchedBanner.dart';
import 'package:demo/api/api_calls.dart';
import 'package:google_fonts/google_fonts.dart';

class CandidatePage extends StatefulWidget {
  const CandidatePage({super.key});

  @override
  State<CandidatePage> createState() => _CandidatePageState();
}

class _CandidatePageState extends State<CandidatePage> {
  late ScrollController _scrollController;
  bool canSwipe = false;
  bool isLoading = true; // Flag to track if data is loading

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    getMatchUsers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getMatchUsers() async {
    setState(() {
      isLoading = true; 
    });
    final startTime = DateTime.now();

    // Checking if wether there is data in this while switching pages
    // Have to implement time feature also
    if (userValues.matchUserDetails.isEmpty){
      userValues.matchUserDetails = await ApiCalls.getMatchCandidates();

      // This will trigger only if matchUserDetails is empty and it is returned empty since snoozeMode is on
      if (userValues.matchUserDetails.isEmpty){
        setState(() {
          isLoading = false; 
          userValues.snoozeEnabled = true;
        });
        return;
      }

      await getUserImages();

      final endTime = DateTime.now();
      final totalTime = endTime.difference(startTime);

      print("Total time taken: $totalTime");


      // Once data fetching is over then flags will be automatically updated to show the screen to the user
      setState(() {
        isLoading = false; 
      });
    }else{
      setState(() {
        isLoading = false; 
      });
    }
  }

  // This function will get all the users from userValues.matchUserDetails images and store it in the userValues.userImageURLs
  Future<void> getUserImages() async {
    for (int c = 0; c < userValues.matchUserDetails.length; c++ ){
      List<dynamic> dataList = userValues.matchUserDetails[c]["ImageDetails"];
      List filteredList = dataList.where((element) => element != null).toList();
      List counterUserImages = [];

      for (var imageString in filteredList) {
        var imageUrl = await firebaseCalls.getCandidateImages(userValues.matchUserDetails[c]["UserDetails"]["uid"], imageString);
        counterUserImages.add(imageUrl);
      }
      userValues.userImageURLs.add(counterUserImages);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color.fromARGB(255, 213, 213, 213))
                  ),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ), 
            )

          : userValues.snoozeEnabled ? 
            // Shown if in snooze mode
            Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Snooze Image
                    Image.asset(
                        "lib/images/snooze.png",
                        height: 100,
                        width: 100,
                    ),
                    SizedBox(height: 20,),

                    // Snooze Mode Text
                    Text("Snooze Mode,\n Activated", style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                    SizedBox(height: 10,),

                    Text("Your profile will be hidden from other's untill you turn off Snooze Mode", style: GoogleFonts.poppins(fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
                    SizedBox(height: 20,),

                    // Button to turn off snooze mode
                    GestureDetector(
                      onTap: () {
                        ApiCalls.disableSnoozeMode();
                        setState(() {
                          userValues.snoozeEnabled = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        decoration: BoxDecoration(
                          color: reuseableColors.accentColor,
                          borderRadius: BorderRadius.circular(25)
                        ),
                        child: Text("Turn off your Snooze Mode", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),),
                      ),
                    )
                  ],
                ),
              ),
              ) 

            // Else normally show users match content
          : Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CardSwiper(
                  padding: EdgeInsets.zero,
                  cardsCount: userValues.matchUserDetails.length,
                  isLoop: false,
                  isDisabled: canSwipe,
                  backCardOffset: const Offset(0, 0),
                  allowedSwipeDirection: const AllowedSwipeDirection.only(right: true, left: true),
                  onSwipe: (previousIndex, currentIndex, direction) async {
                    // This makes sure the next card is always in the top
                    _scrollController.jumpTo(0.0);

                    // This is to ensure that the server doesnt get abused with multiple requests causing data to be overwritten
                    // {Disabled for now for smoother testing}
                    // setState(() {
                    //   canSwipe = true;
                    //   Future.delayed(const Duration(seconds: 2), () {
                    //     setState(() {
                    //       canSwipe = false;
                    //     });
                    //   });
                    // });

                    // This int keeps track of how many users have been swiped and then if the user visits any other page then deletes them from the list
                    userValues.userVisited++;

                    if (direction == CardSwiperDirection.right){
                      // Pass the data to call the api (Liked User) 
                      Map data = {
                        "type": "LikedUser",
                        "uid": userValues.uid,
                        "key": userValues.cookieValue,
                        "matchUID": userValues.matchUserDetails[previousIndex]["UserDetails"]["uid"],
                        "matchName": userValues.matchUserDetails[previousIndex]["UserDetails"]["name"],
                        "userName": userValues.userData["name"]
                      };
                      print(data);
                      ApiCalls.swipeActionsMatch(data).then((response) {
                        dynamic decodedResponse = jsonDecode(response);
                        if (decodedResponse["identifier"] == 1){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => matchedBannerPage(matchUID: decodedResponse["uid"], imageName: decodedResponse["imageName"],)),);
                          print("Match Found");
                        }
                      });
                    }
                    else{
                      // Pass the data to call the api (Disliked User) 
                      Map data = {
                        "type": "DislikedUser",
                        "uid": userValues.uid,
                        "key": userValues.cookieValue,
                        "matchUID": userValues.matchUserDetails[previousIndex]["UserDetails"]["uid"]
                      };
                      ApiCalls.swipeActionsMatch(data);
                    }
                    return true;
                  },
                  cardBuilder: (context, index, x, y) {
                      return CandidateDetailsContainer(scrollController: _scrollController, candidateDetails: userValues.matchUserDetails[index], userImageList: userValues.userImageURLs[index]);
                  },
                ),
              ),
            ),
    );
  }
}
