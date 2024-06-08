// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, sort_child_properties_last, library_private_types_in_public_api
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:linkup/colors/colors.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/elements/candidate_page_elements/elements.dart';
import 'package:linkup/pages/chat_sub_pages/chat_details.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef SendMessageCallback = void Function(Map<String, dynamic> message);

Map chatUserDetails = {
  "uid": userValues.uid,
  "key" : userValues.cookieValue,
  'type': 'GetChatUserDetails',
};

Map writeChatData = {
  "uid": userValues.uid,
  "key" : userValues.cookieValue,
  'type': 'WriteChats',
};

Widget normalPadding(Widget child) {
  return Padding(
    padding: EdgeInsets.only(left: 10),
    child: child,
  );
}

Widget chatTitle() {
  return normalPadding(
    Text(
      "Chats",
      style: GoogleFonts.nunitoSans(
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
    ),
  );
}

Widget matchQueTitle(){
  return normalPadding(
    Text(
      "Match Queue",
      style: GoogleFonts.nunitoSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    )
  );
}

// Message widget you see under chats
class ChatDetails extends StatefulWidget {
  final int index;
  final String path;
  final String matchUID;
  final String name;

  const ChatDetails({super.key, required this.index, required this.matchUID, required this.path, required this.name});

  @override
  _ChatDetailsState createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  String lastMessage = '';
  bool isCurrentUserLastSender = true;
  String? chatUserImage; // Define a variable to store the chat user image URL
  bool isImageLoaded = false; // Track whether the image is already loaded

  @override
  void initState() {
    super.initState();
    // Initialize lastMessage when the widget is first created
    _fetchLastMessage();
  }

  // Function to fetch last message of each chat users
  void _fetchLastMessage() async {
    DatabaseReference lastMessageRef = FirebaseDatabase.instance.ref('/UserChats/${widget.path}/ChatDetails/LastMessageDetails/');
    lastMessageRef.onValue.listen((event) {
      Map? lastMessageDetails = event.snapshot.value as Map <dynamic,dynamic>;
      String lastMessegedUser = lastMessageDetails["lastMessageUser"];

      setState(() {
        if (lastMessegedUser.trim() != userValues.uid) {
          isCurrentUserLastSender = false;
        } else {
          isCurrentUserLastSender = true;
        }
        lastMessage = lastMessageDetails["lastMessage"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Call function to fetch chat user image
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailsPage(
              appBarTitle: widget.name,
              imageUrl: "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${widget.matchUID}%2F${userValues.chatUsers[widget.matchUID]["imageLink"]}?alt=media&token",
              path: widget.path,
              matchUID: widget.matchUID,
              notChatPage: true,
            ),
          ),
        );
      },
      
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent, // Color set to transparent for some reason the click doesnt count if there is no color
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: 90,
        child: Row(
          children: [
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${widget.matchUID}%2F${userValues.chatUsers[widget.matchUID]["imageLink"]}?alt=media&token",
                fit: BoxFit.cover,
                width: 65,
                height: 65,
              ),
            ),
            SizedBox(width: 13),

            Expanded(
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          Text(
                            lastMessage,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8), 

                    // If last message user is currentUser then return only container else return notifation dot
                    isCurrentUserLastSender ? Container()
                    : Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Theme.of(context).splashColor,
                          shape: BoxShape.circle,
                        ),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Matches you see under Match Queue
class MatchedUserWidget extends StatefulWidget {
  
  @override
  State<MatchedUserWidget> createState() => _MatchedUserWidgetState();
}

class _MatchedUserWidgetState extends State<MatchedUserWidget> {
  Map <String, dynamic> localMatchUserData = userValues.matchedUsers;

  @override
  void initState(){
    super.initState();
    fetchMatchesRealtime();
  }

  void fetchMatchesRealtime() async{
    final matchUsersRef = FirebaseDatabase.instance.ref().child("/UserMatchingDetails/${userValues.uid}/MatchUID");
    
    matchUsersRef.onChildAdded.listen((event) async { // Constantly listen to children being added and then make change
      final data = await event.snapshot.value as Map; 

      if (localMatchUserData[event.snapshot.key.toString()] == null){ // If matchUser is new then create new map and start
        localMatchUserData[event.snapshot.key.toString()] = {};
      }

      localMatchUserData[event.snapshot.key.toString()]["uniquePath"] = data["uniquePath"]; 
      localMatchUserData[event.snapshot.key.toString()]["userName"] = data["matchName"];  
      localMatchUserData[event.snapshot.key.toString()]["userImage1"] = "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${event.snapshot.key.toString()}%2F${data["imageName"]}?alt=media&token" ; 

      // userValues.chatUserImages[event.snapshot.key.toString()] = localMatchUserData[event.snapshot.key.toString()]["imageLink"];
    
      setState(() {
        localMatchUserData;
      });

      userValues.matchedUsers = localMatchUserData;
    },);

    matchUsersRef.onChildRemoved.listen((event) async{
      localMatchUserData.remove(event.snapshot.key);
      userValues.matchedUsers.remove(event.snapshot.key);
      userValues.matchUserData.remove(event.snapshot.key);
      
      setState(() {
        localMatchUserData;
      });
    });
  }

  Widget build(BuildContext context) {
    // Widgets built will be stored here
    List<Widget> userImages = [];

    // Check if matchedUsers is not null
    if (localMatchUserData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          children: [
            Image.asset(
              'lib/images/cards_stack.png',
              width: 80,
              height: 80,
            ),
            SizedBox(width: 10),
            Text(
              "Your matches will appear here",
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
      );
    }

    localMatchUserData.forEach((key, value) {
      String userImage = value["userImage1"]; // UserImages
      userImages.add(
        GestureDetector(
          onTap: () {
            popupMatchDetails(context, value, key, localMatchUserData); // Details passed to popUp Container
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 4,
                ),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: userImage,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ),
      );
    });

    return SizedBox(
      height: 90,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: userImages,
        ),
      ),
    );
  }
}


class chatDetailsChatPage extends StatefulWidget {
  @override
  State<chatDetailsChatPage> createState() => _chatDetailsChatPageState();
}

class _chatDetailsChatPageState extends State<chatDetailsChatPage> {
  Map<String, dynamic> localMatchUserData = userValues.chatUsers; // Create a local variable to store data

  @override
  void initState() {
    super.initState();

    fetchChatsRealtime(); // Get chats from database realtime
  }

  void fetchChatsRealtime() async{
    final chatUserRef = FirebaseDatabase.instance.ref('/UserMatchingDetails/${userValues.uid}/ChatUID/');
    
    chatUserRef.onChildAdded.listen((event) async { // Constantly listen to children being added and then make change
      final data = await event.snapshot.value as Map; 

      data.forEach((key, value) async {
        // Create empty map for storing them locally in this function

        localMatchUserData[event.snapshot.key.toString()] = {}; // Key is uid of user

        // Value saved as [name, path, imageLink]
        var splitted = value.split(",");

        localMatchUserData[event.snapshot.key.toString()]["uniquePath"] = splitted[0]; 
        localMatchUserData[event.snapshot.key.toString()]["userName"] = splitted[1];  
        localMatchUserData[event.snapshot.key.toString()]["imageLink"] = splitted[2]; 

        userValues.chatUserImages[event.snapshot.key.toString()] = localMatchUserData[event.snapshot.key.toString()]["imageLink"];


      });
      
      setState(() {
        localMatchUserData;
      });
    },);

  }


  Widget build(BuildContext context) {
    // This will return only if the chatlist is empty i.e if the user has no one to message 
    if (userValues.chatUsers.isEmpty){
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 80,),
              Opacity(
                opacity: 0.3,
                child: Image.asset(
                  // This will load the sad image face if there are no chats for the user also it depends on the theme that is set
                  Theme.of(context).brightness == Brightness.dark ? "lib/images/empty_chat_white.png" : "lib/images/empty_chat.png",
                  height: 100,
                  width: 100,
                ),
              ),
              SizedBox(height: 30,),
              Text("Find your conversations here", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),),
              SizedBox(height: 5,),
              Text("Step 1: You swipe right", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey ),),
              Text("Step 2: They swipe right, too", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),),
              Text("Step 3: It's a match", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),),

            ],
          )
        )
      );
    }

    // This is when the user has other users to message to 
    else{
      return Expanded(
        child: ListView.builder(
          itemCount: localMatchUserData.length,
          itemBuilder: (_, index) {
            print(index);
            // Access key and value within the loop
            String key = localMatchUserData.keys.elementAt(index);
            String path = localMatchUserData.values.elementAt(index)["uniquePath"];
            String name = localMatchUserData.values.elementAt(index)["userName"];
            // Use key and value to build ChatDetails widget
        
            return Column(
              children: [
                Slidable(
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (v){
                          // Delete chat
                          
                        },
                        backgroundColor: Color(0xFFFE4A49),
                        autoClose: true,
                        padding: EdgeInsets.zero,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                      )
                    ],
                  ),
                  child: ChatDetails(index: index, matchUID: key, path: path, name: name,)
                ),
                SizedBox(height: 10),
              ],
            );
          },
        ),
      );
    }
  }
}


Widget matchedUsers() {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0, top: 10),
    child: MatchedUserWidget()
  );
}

Future popupMatchDetails(BuildContext context, Map value, String key, Map<String, dynamic> matchedUsersNew) {
  return showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context, ) {
      // Calculate the height of the popup surface
      double popupHeight = MediaQuery.of(context).size.height * 0.8;
      return FutureBuilder(
        future: fetchData(key),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List matchUserImages = snapshot.data["ImageDetails"];
            matchUserImages = matchUserImages.where((image) => image != null).toList();

            Map matchUserData = snapshot.data["UserDetails"];
            return Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoPopupSurface(
                    child: IntrinsicHeight(
                      child: SizedBox(
                        height: popupHeight, 
                        child: SingleChildScrollView(
                          // Wrap the content in a SingleChildScrollView
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Match user userImage1
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFD9D9D9),
                                ),
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${matchUserData["uid"]}%2F${matchUserImages[0]}?alt=media&token",
                                      fit: BoxFit.cover,
                                      height: popupHeight,
                                      placeholder: (context, url) =>
                                          Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left: 15,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${matchUserData["name"]}, ${matchUserData["age"]}',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 26,
                                              decoration: TextDecoration.none,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.school_outlined, color: Colors.white),
                                              SizedBox(width: 5),
                                              Text(
                                                'Doing ${matchUserData["stream"]}',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  decoration: TextDecoration.none,
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
                              // Match user tags
                              IntrinsicHeight(
                                child: Material(
                                  child: aboutMeAndTags(data: matchUserData),
                                  color: reuseableColors.primaryColor,
                                ),
                              ),
                              // Match user userImage2
                              Container(
                                height: 700,
                                color: Color(0xFFD9D9D9),
                                child: CachedNetworkImage(
                                  imageUrl: "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${matchUserData["uid"]}%2F${matchUserImages[1]}?alt=media&token",
                                  height: popupHeight,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                              //Match user location or stream details
                              IntrinsicHeight(
                                child: Material(
                                  child: fromOrStreamDetails(buttonsNeeded: false, candidateDetails: matchUserData),
                                  color: reuseableColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailsPage(appBarTitle: matchUserData["name"], imageUrl: value["userImage1"], path: matchedUsersNew[key]["uniquePath"], matchUID: matchUserData["uid"], notChatPage: false,),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: reuseableColors.accentColor,
                      ),
                      child: Center(child: Material(color: reuseableColors.accentColor, child: Text("Start Messaging", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),)),),
                    ),
                  )
                ],
              ),
            );
          }
        }
      );
    },
  );

}

// Function to fetch data for popUp Banner
Future<Map> fetchData(String key) async {
  chatUserDetails["chatUID"] = key;

  // Check if data already exists if yes then skip this 
  if (userValues.matchUserData[key] == null){
    // If no then get data and return
    await ApiCalls.getChatUserData(chatUserDetails);
  }
  
  return userValues.matchUserData[key];
}

// This is where the matchUsers pfp is worked also active listener for new data

Widget MessageContent(messages, ScrollController _scrollController){
  return Positioned.fill (
    child: SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10,),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              for (var message in messages)
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  // If not currentUser message 
                  child: message["sender"] == "user2" ? Padding(
                    // Padding for gap between messages
                    padding: const EdgeInsets.only(bottom: 0.0, left: 8.0, top: 4.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        // Padding for message content in the box
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 226, 226),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 300, minWidth: 20), // Maximum, miniumum width 
                          child: Text(
                            message["text"],
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
                            textAlign: message["text"].length >= 10 ? TextAlign.left : TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  // If currentUser message
                  ) : Padding(
                    // Padding for gap between messages
                    padding: const EdgeInsets.only(bottom: 0.0, right: 8.0, top: 4.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF193046),
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), topLeft: Radius.circular(20), topRight: Radius.circular(20),),
                        ),
                        // Padding for messages inside the box
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 300, minWidth: 20), // Maximum, miniumum width 
                          child: Text(
                            message["text"],
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w300),
                            textAlign: message["text"].length >= 10 ? TextAlign.left : TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget ActionWidget(String matchUID){
  return ClipRRect(
    borderRadius: BorderRadius.circular(20), // Adjust the border radius as needed
    child: PopupMenuButton(
      itemBuilder: (_) => <PopupMenuEntry>[
        PopupMenuItem(
          value: 'option1',
          child: Text('Unmatch'),
        ),
        PopupMenuItem(
          value: 'option2',
          child: Text('Block and report'),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'option1':
            Map unMatchUser = {
              "type": "UnmatchUser",
              "key" : userValues.cookieValue,
              "matchUserID": matchUID
            };
            break;
          case 'option2':
            break;
        }
      },
    ),
  );
}
