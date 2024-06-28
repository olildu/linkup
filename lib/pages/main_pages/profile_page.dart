import 'package:firebase_database/firebase_database.dart';
import 'package:linkup/colors/colors.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/elements/profile_elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();

}

class _ProfilePageState extends State<ProfilePage> {
  dynamic userData;
  bool isDataLoaded = true;
  bool aboutMeClicked = false;

  @override
  void initState() {
    super.initState();
    fetchuserData();
  }

  @override
  void dispose(){
    super.dispose();
  }
 
  Future<void> fetchuserData() async{
    final userDetailsref = FirebaseDatabase.instance.ref().child("/UsersMetaData/${UserValues.uid}/UserDetails");

    userDetailsref.onValue.listen((event) {
      setState(() {
        UserValues.userData = event.snapshot.value as Map<dynamic, dynamic>;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: 
      LiquidPullToRefresh(
        onRefresh: fetchuserData,
        animSpeedFactor: 2,
        showChildOpacityTransition: false,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photos Title
                  titleAndSubtitle("Your Photos", "Add photos that show your true self", subTitleColor: Theme.of(context).colorScheme.secondaryContainer),
                  
                  const SizedBox(height: 30), 
                  // Photos
                  const PhotosWidget(),
        
                  const SizedBox(height: 40), 
                  // About Me Title
                  titleAndSubtitle("About Me", "Write something that catches the eye", subTitleColor: Theme.of(context).colorScheme.secondaryContainer),
        
                  const SizedBox(height: 30), 
                  // About Me Container
                  aboutMeContainer(
                    initialValue: UserValues.userData["aboutMe"] ?? "",
                    onPressed: () {
                      setState(() {
                        aboutMeClicked = true;
                      });
                    },
                    onFocusLost: () {
                      setState(() {
                        aboutMeClicked = false;
                      });
                    }
                  ),
        
                  if (aboutMeClicked)
                  Column(
                    children: [
                      const SizedBox(height: 20,),
                      Align(
                      alignment: Alignment.centerRight,
                      child: FloatingActionButton(onPressed: (){
                        setState(() {
                          aboutMeClicked = false;
                        });
                        Map userDataTags = {
                          "uid": UserValues.uid,
                          'type': 'uploadTagData',
                          'key': UserValues.cookieValue,
                          'keyToUpdate': "aboutMe",
                          'value': controller.text
                        };
                        ApiCalls.storeUserMetaData(userDataTags);
                      },
                      backgroundColor: ReuseableColors.accentColor,
                      shape: const CircleBorder(),
                      child: const ClipOval(child: Icon(Icons.done_rounded, color: Colors.white,)),),),
                    ],
                  ),
        
                  const SizedBox(height: 20), 
        
                  // More About Me Title
                  titleAndSubtitle("More about me", "Things most people are curious about", subTitleColor: Theme.of(context).colorScheme.secondaryContainer),
        
                  const SizedBox(height: 30), 
        
                  // More About Me Children
                  moreAboutMeChildren(context, UserValues.userData),
        
                  const SizedBox(height: 40), 
        
                  // My Basics Title
                  titleAndSubtitle("My basics", "Get your basics right", subTitleColor: Theme.of(context).colorScheme.secondaryContainer),
        
                  const SizedBox(height: 30), 
        
                  //My Basics Chilren
        
                  myBasicsChildren(context, UserValues.userData)
        
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
