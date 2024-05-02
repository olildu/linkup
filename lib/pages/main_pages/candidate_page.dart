import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:demo/elements/candidate_details_elements/elements.dart';
import 'package:demo/api/api_calls.dart';

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

    // Checking if wether there is data in this 
    // Have to implement time feature also
    if (userValues.matchUserDetails.isEmpty){
      userValues.matchUserDetails = await ApiCalls.getMatchCandidates();
      await getUserImages();

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
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color.fromARGB(255, 213, 213, 213))
                  ),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ), 
            )
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
                    setState(() {
                      canSwipe = true;
                      Future.delayed(const Duration(seconds: 2), () {
                        setState(() {
                          canSwipe = false;
                        });
                      });
                    });

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
                      ApiCalls.LikeMatch(data);
                    }
                    else{
                      // Pass the data to call the api (Disliked User) 
                      Map data = {
                        "type": "DislikedUser",
                        "uid": userValues.uid,
                        "key": userValues.cookieValue,
                        "matchUID": userValues.matchUserDetails[previousIndex]["UserDetails"]["uid"]
                      };
                      ApiCalls.dislikeMatch(data);
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
