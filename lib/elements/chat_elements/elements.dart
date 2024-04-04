// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, sort_child_properties_last
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo/Colors.dart';
import 'package:demo/api/api_calls.dart';
import 'package:demo/elements/candidate_details_elements/elements.dart';
import 'package:demo/elements/candidate_page_elements/elements.dart';
import 'package:demo/elements/create_profile_elements/elements.dart';
import 'package:demo/pages/chat_sub_pages/chat_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

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

class ChatDetails extends StatefulWidget {
  final int index;

  const ChatDetails({super.key, required this.index});

  @override
  _ChatDetailsState createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  bool isClicked = false;
  Color flashColor = Color.fromARGB(255, 237, 237, 237);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
    onTap: () {
      setState(() {
        isClicked = !isClicked;
        flashColor = Color.fromARGB(255, 237, 237, 237);
      });

      Future.delayed(Duration(milliseconds: 50), () {
        setState(() {
          flashColor = const Color.fromARGB(0, 219, 219, 219); 
        });
        
        Future.delayed(Duration(), () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ChatDetailsPage(appBarTitle: "Name${widget.index}", imageUrl: "lib/images/user.png"),
          //   ),
          // );
        });
      });
    },

      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        color: isClicked ? flashColor : Colors.white, 
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: Container(
            height: 90,
            color: Colors.transparent,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("lib/images/user.png"),
                ),
                SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name${widget.index}",
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "Last Message",
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget matchedUser(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0, top: 10),
    child: FutureBuilder<Widget>(
      future: _buildMatchedUserWidget(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Display a loading indicator while data is being fetched
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Display an error message if fetching data fails
        } else {
          return snapshot.data ?? SizedBox(); // Display the matched user images widget, or an empty SizedBox if data is null
        }
      },
    ),
  );
}

Future popupMatchDetails(BuildContext context, Map value, String key, Map<String, dynamic>? matchedUsersNew) {
  chatUserDetails["chatUID"] = key;

  return showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      // Calculate the height of the popup surface
      double popupHeight = MediaQuery.of(context).size.height * 0.8;

      return FutureBuilder(
        future: fetchData(value, key),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasError) {
              // Handle error case
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
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
                                        imageUrl: value["userImage1"],
                                        fit: BoxFit.cover,
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
                                //Match user userImage1
                                Container(
                                  height: 700,
                                  color: Color(0xFFD9D9D9),
                                  child: CachedNetworkImage(
                                    imageUrl: value["userImage2"],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                ),
                                //Match user location or stream details
                                IntrinsicHeight(
                                  child: Material(
                                    child: fromOrStreamDetails(buttonsNeeded: false, data: matchUserData),
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
                        print(matchedUsersNew?[key]["uniquePath"]);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailsPage(appBarTitle: matchUserData["name"], imageUrl: value["userImage1"], path: matchedUsersNew?[key]["uniquePath"], matchUID: matchUserData["uid"]),
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
        },
      );
    },
  );

}

// Function to fetch data asynchronously
Future<Map> fetchData(Map value, String key) async {
  try {
    if (userValues.matchUserDataNew[key] == null) {
      await ApiCalls.getChatUserData(chatUserDetails);
    }
    return userValues.matchUserDataNew[key];
  } catch (e) {
    throw Exception('Failed to fetch data: $e');
  }
}


Map<String, dynamic>? matchedUsers;

Future<Widget> _buildMatchedUserWidget(BuildContext context) async {
  // Check if matchedUsers has already been fetched
  if (!flagChecker.matchQueFetched) {
    matchedUsers = await ApiCalls.GetMatchedUsers();
    flagChecker.matchQueFetched = true;
  }

  // Widgets built will be stored here
  List<Widget> userImages = [];
  // Check if matchedUsers is not null
  if (matchedUsers != null) {
    matchedUsers!.forEach((key, value) {
      String userImage = value["userImage1"];
      userImages.add(
        GestureDetector(
          onTap: () {
            popupMatchDetails(context, value, key, matchedUsers);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 4),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child : CachedNetworkImage(
                  imageUrl: userImage,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(), 
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
          
              ),
            ),
          ),
        ),
      );
    });
  }

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

Widget chatDetailsStructure(){
  return Expanded( 
    child: ListView.builder(
      itemCount: 10,
      itemBuilder: (_, index) => Column(
        children: [
          ChatDetails(index: index),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}

typedef SendMessageCallback = void Function(Map<String, dynamic> message);




Widget MessageContent(messages){
  return Positioned.fill(
    child: SingleChildScrollView(
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
                  child: message["sender"] == "user2" ? Padding(
                    padding: const EdgeInsets.only(bottom: 0.0, left: 8.0, top: 4.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 226, 226),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 300), // Set maximum width here
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                            child: Text(
                              message["text"],
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ) : Padding(
                    padding: const EdgeInsets.only(bottom: 0.0, right: 8.0, top: 4.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF193046),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 300), // Set maximum width here
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                            child: Text(
                              message["text"],
                              style: TextStyle(color: Colors.white),
                            ),
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

Widget ActionWidget(){
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
            break;
          case 'option2':
            break;
        }
      },
    ),
  );
}