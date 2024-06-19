import 'dart:convert';

import 'package:linkup/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:linkup/elements/candidate_details_elements/elements.dart';
import 'package:linkup/pages/match_banner_page/matchedBanner.dart';
import 'package:linkup/api/api_calls.dart';
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

    // Checking if wether there is data in this while switching pages
    // Have to implement time feature also
    if (UserValues.matchUserDetails.isEmpty && UserValues.snoozeEnabled == false){
      UserValues.matchUserDetails = await ApiCalls.getMatchCandidates();


      // Temporary solution, cant find solution for only when 1 user is available
      if (UserValues.matchUserDetails.length == 1){
        setState(() {
          UserValues.limitReached = true;
        });
      }

      /* This will trigger only if matchUserDetails is empty and it is returned empty since snoozeMode is on also will check if the 
        the UserValues.snoozeEnabled is true if it is not then its likely means there are no candidates the user can see */
      if (UserValues.matchUserDetails.isEmpty && UserValues.snoozeEnabled == true){
        setState(() {
          isLoading = false; 
          UserValues.snoozeEnabled = true;
        });
        return;
      }

      // This will trigger when matchUserDetails is empty meaning there is no candidates for the user to see and hence shows the message
      if (UserValues.matchUserDetails.isEmpty){
        setState(() {
          isLoading = false; 
          UserValues.limitReached = true;
        });
        return;
      }

      await getUserImages();

      UserValues.counterCandidatesAvailable = UserValues.matchUserDetails.length;

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

  // This function will get all the users from UserValues.matchUserDetails images and store it in the UserValues.userImageURLs
  Future<void> getUserImages() async {
    for (int c = 0; c < UserValues.matchUserDetails.length; c++ ){
      List<dynamic> dataList = UserValues.matchUserDetails[c]["ImageDetails"];
      List filteredList = dataList.where((element) => element != null).toList();
      List counterUserImages = [];

      for (var imageString in filteredList) {
        var imageUrl = await FirebaseCalls.getCandidateImages(UserValues.matchUserDetails[c]["UserDetails"]["uid"], imageString);
        counterUserImages.add(imageUrl);
      }
      UserValues.userImageURLs.add(counterUserImages);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: isLoading
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                  color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).colorScheme.secondary)
                  ),
                  child: Center(child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  )),
                ),
              ), 
            )

          : UserValues.snoozeEnabled ? 
            // Shown if in snooze mode is enabled
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
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
                    const SizedBox(height: 20,),

                    // Snooze Mode Text
                    Text("Snooze Mode,\n Activated", style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                    const SizedBox(height: 10,),

                    Text("Your profile will be hidden from other's untill you turn off Snooze Mode", style: GoogleFonts.poppins(fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
                    const SizedBox(height: 20,),

                    // Button to turn off snooze mode
                    GestureDetector(
                      onTap: () {
                        ApiCalls.disableSnoozeMode();
                        setState(() {
                          UserValues.snoozeEnabled = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        decoration: BoxDecoration(
                          color: ReuseableColors.accentColor,
                          borderRadius: BorderRadius.circular(25)
                        ),
                        child: Text("Turn off your Snooze Mode", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),),
                      ),
                    )
                  ],
                ),
              ),
              ) 

          // When the user has finished their like quota
          : UserValues.limitReached ? 
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // No more likes image
                    Image.asset(
                        "lib/images/sad.png",
                        height: 100,
                        width: 100,
                    ),
                    const SizedBox(height: 20,),

                    // No more likes Text
                    Text("Whoops!\nThat's all we have!", style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                    const SizedBox(height: 20,),

                    Text("You've spread all the love you can for now. Come back later to find more amazing people!", style: GoogleFonts.poppins(fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
                    const SizedBox(height: 20,),
                  ],
                ),
              ),
              ) 
          :
          // Else normally show users match content
          Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CardSwiper(
                  padding: EdgeInsets.zero,
                  cardsCount: UserValues.matchUserDetails.length,
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
                    UserValues.userVisited++;

                    // This int keeps track of how many candidates the user has seen and when it becomes zero no more matches available is shown
                    UserValues.counterCandidatesAvailable--;

                    if (UserValues.counterCandidatesAvailable <= 0) {
                      setState(() {
                        UserValues.limitReached = true;
                      });
                    }

                    if (direction == CardSwiperDirection.right){
                      // Pass the data to call the api (Liked User) 
                      Map data = {
                        "type": "LikedUser",
                        "uid": UserValues.uid,
                        "key": UserValues.cookieValue,
                        "matchUID": UserValues.matchUserDetails[previousIndex]["UserDetails"]["uid"],
                        "matchName": UserValues.matchUserDetails[previousIndex]["UserDetails"]["name"],
                        "userName": UserValues.userData["name"]
                      };
                      ApiCalls.swipeActionsMatch(data).then((response) {
                        dynamic decodedResponse = jsonDecode(response);
                        if (decodedResponse["identifier"] == 1){ // Identifier 1 means match found
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MatchedBannerPage(matchUID: decodedResponse["uid"], imageName: decodedResponse["imageName"],)),);
                        }
                      });
                    }
                    else{
                      // Pass the data to call the api (Disliked User) 
                      Map data = {
                        "type": "DislikedUser",
                        "uid": UserValues.uid,
                        "key": UserValues.cookieValue,
                        "matchUID": UserValues.matchUserDetails[previousIndex]["UserDetails"]["uid"]
                      };
                      ApiCalls.swipeActionsMatch(data);
                    }
                    return true;
                  },
                  cardBuilder: (context, index, x, y) {
                      return CandidateDetailsContainer(scrollController: _scrollController, candidateDetails: UserValues.matchUserDetails[index], userImageList: UserValues.userImageURLs[index]);
                  },
                ),
              ),
            ),
    );
  }
}
