// ignore_for_file: prefer_const_constructors, prefer_final_fields, sort_child_properties_last

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo/api/api_calls.dart';
import 'package:demo/elements/chat_elements/elements.dart';
import 'package:demo/colors/colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:demo/elements/candidate_page_elements/elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatDetailsPage extends StatefulWidget {
  final String appBarTitle;
  final String imageUrl;
  final String path;
  final String matchUID;

  const ChatDetailsPage({super.key, required this.appBarTitle, required this.imageUrl, required this.path, required this.matchUID,});

  @override
  _ChatDetailsPageState createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  TextEditingController _messageController = TextEditingController();
    

  List<Map<String, dynamic>> _messages = [

  ];

  void _addMessage(Map<String, dynamic> message) {
    setState(() {
      _messages.add(message);
    });
  }

  void initState() {
    super.initState();
    // Call your asynchronous method inside a separate function
    _fetchChatMessages();
  }

  void _fetchChatMessages() async {
    DatabaseReference userMatchRef = FirebaseDatabase.instance.ref('/UserChats/${widget.path}/');
    int x = 1;
    // Listen for data changes
    userMatchRef.onValue.listen((DatabaseEvent event) {
      Map<dynamic, dynamic>? chatList = event.snapshot.value as Map<dynamic, dynamic>?;
      
    if (chatList != null && chatList["Messages"] != null) {
      List<dynamic> messages = chatList["Messages"];

      for (x; x < messages.length; x++) {
        Map message = messages[x];
        String sender = message["uid"];

        if (sender == userValues.uid) {
          sender = "user1";
        } else {
          sender = "user2";
        }

        String content = message["content"];
        // Assuming timeStamp is stored as an int in Firebase, you might need to convert it accordingly
        double timeStamp = message["timeStamp"];

        _addMessage({
          "text": content,
          "sender": sender
        });
      }
    }

    });

    // Wait for the Completer to complete and ge
    // Process the chat messages

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Theme.of(context).colorScheme.background,
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      shadowColor: Colors.black,
      leading: InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Row(
          children: const [
            SizedBox(width: 20),
            Icon(Icons.arrow_back_ios),
          ],
        ),
      ),
      title: GestureDetector(
        onTap: () {
          userValues.matchedUsers!.forEach((key, value) {
            popupMatchDetails(context, value, key, userValues.matchedUsers);
            }
          );
        },
        child: Transform.translate(
          offset: Offset(-22, 0),
          child: Row(
            children: [
              ClipOval(
              child : CachedNetworkImage(
                imageUrl: widget.imageUrl,
                width: 38,
                height: 38,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(), 
                errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              SizedBox(width: 10),
              Text(widget.appBarTitle),
            ],
          ),
        ),
      ),
      actions: [
        ActionWidget(widget.matchUID)
      ],
    
    ),
    body: Stack(
      children: [
        MessageContent(_messages),
        TextFieldWithDynamicColor(sendMessage: _addMessage, path: widget.path, matchUID: widget.matchUID),
      ],
    ),
        );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class TextFieldWithDynamicColor extends StatefulWidget {
  final SendMessageCallback sendMessage;
  final String path;
  final String matchUID;

  TextFieldWithDynamicColor({required this.sendMessage, required this.path, required, required this.matchUID});
  @override
  _TextFieldWithDynamicColorState createState() => _TextFieldWithDynamicColorState();
}

class _TextFieldWithDynamicColorState extends State<TextFieldWithDynamicColor> {
  TextEditingController messageController = TextEditingController();
  Color containerColor = Colors.grey;
  String imagePath = "lib/images/send-icon-disabled.png";
  
  @override
  void initState() {
    super.initState();
    messageController.addListener(() {
      setState(() {
        if (messageController.text.trim().isNotEmpty) {
          imagePath = "lib/images/send-icon-enabled.png";
          containerColor = reuseableColors.primaryColor;
        } else {
          imagePath = "lib/images/send-icon-disabled.png";
          containerColor = Colors.grey;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return NewTextField(sendMessage: widget.sendMessage, messageController: messageController, containerColor: containerColor, imagePath: imagePath, path: widget.path, matchUID: widget.matchUID, context: context);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}

Widget NewTextField({required BuildContext context, required SendMessageCallback sendMessage, required TextEditingController messageController, required Color containerColor, required String imagePath, required String path, required String matchUID}) {
  return Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background
      ),
      child: Row(
        children: [
          Expanded( 
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Aa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary), // Border color when not focused
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.surface), // Border color when focused
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 4,
            ),
          ),
          SizedBox(width: 5,),
          GestureDetector(
            onTap: () {
              if (messageController.text.trim().isNotEmpty) {
                sendMessage({
                  "text": messageController.text.trim(),
                  "sender": "user1"
                });

                writeChatData["content"] = messageController.text.trim(); 
                writeChatData["uniquePath"] = path; 
                writeChatData["matchUID"] = matchUID;   

                print(writeChatData);

                ApiCalls.writeChatContent(writeChatData);
                messageController.clear();
              }
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: Offset(-2,0),
                  child: Image.asset(imagePath, width: 19, height: 19,)
                ),
              ),
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(50)
              ),
            ),
          )
        ],
      ),
    ),
  );
}

Future popupMatchDetails(BuildContext context, Map value, String key, Map<String, dynamic>? matchedUsersNew) {
  chatUserDetails["chatUID"] = key;
  return showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context, ) {
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
                                //Match user userImage1
                                Container(
                                  height: 700,
                                  color: Color(0xFFD9D9D9),
                                  child: CachedNetworkImage(
                                    imageUrl: value["userImage2"],
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
