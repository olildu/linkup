// ignore_for_file: prefer_const_constructors, prefer_final_fields, sort_child_properties_last

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/elements/chat_elements/elements.dart';
import 'package:linkup/colors/colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:linkup/elements/candidate_page_elements/elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatDetailsPage extends StatefulWidget {
  final String matchName;
  final String imageUrl;
  final String path;
  final String matchUID;
  final bool notChatPage;

  const ChatDetailsPage({super.key, required this.matchName, required this.imageUrl, required this.path, required this.matchUID, this.notChatPage = true});

  @override
  ChatDetailsPageState createState() => ChatDetailsPageState();
}

class ChatDetailsPageState extends State<ChatDetailsPage> {
  TextEditingController _messageController = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];

  void _addMessage(Map<String, dynamic> message) {
    setState(() {
      scrollDown();
      _messages.add(message);
    });
  }

  @override
  void initState() {
    super.initState();
    
    // Fetch messages required 
    fetchChatMessages();

    // Change required notificationHandlers
    UserValues.notificationHandlers["allowNotification"] = true;
    UserValues.notificationHandlers["currentMatchUID"] = widget.matchUID;

    UserValues.shouldLoad = true;

    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());

    myFocusNode.addListener(() {
      if(myFocusNode.hasFocus){
        Future.delayed(const Duration(milliseconds: 700), () => scrollDown());
      }
    });
  }

  @override
  void dispose() {
    if (!widget.notChatPage){
      UserValues.notificationHandlers["allowNotification"] = false;
      if (UserValues.usersNotificationCounter.contains(widget.matchUID)){
        
        UserValues.notificationCount--;
      }
    }

    UserValues.notificationHandlers["currentMatchUID"] = null;

    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void scrollDown(){
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
    duration: const Duration(milliseconds: 500),
    curve: Curves.fastOutSlowIn
  );  
}

  void fetchChatMessages() async {
    DatabaseReference userMatchRef = FirebaseDatabase.instance.ref('/UserChats/${widget.path}/Messages');

    userMatchRef.onChildAdded.listen((event) {
      Map messages = event.snapshot.value as Map;

      String message = messages["content"];
      String sender = messages["uid"];

      if (sender == UserValues.uid) {
        sender = "user1";
      } else {
        sender = "user2";
      }
      
      /* UserValues.shouldLoad will be set to false if the users has sent a message
            because else there will messages coming twice in the UI */
      if ((UserValues.shouldLoad == true) || (messages["uid"] != UserValues.uid)){
        _addMessage({
          "text": message,
          "sender": sender
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).secondaryHeaderColor,
        statusBarIconBrightness: UserValues.darkTheme ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Theme.of(context).secondaryHeaderColor,
      ),
      child: Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
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
            UserValues.chatUsers.forEach((key, value) {
              popupMatchDetails(context, value, key);
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
                Text(widget.matchName, style: GoogleFonts.poppins(),),
              ],
            ),
          ),
        ),
        actions: [
          actionWidget(widget.matchUID, context, widget.matchName)
        ],
      
      ),
      body: Stack(
        children: [
          messageContent(context, _messages, _scrollController),
          TextFieldWithDynamicColor(sendMessage: _addMessage, path: widget.path, matchUID: widget.matchUID, focusNode: myFocusNode,),
        ],
      ),
          ),
    );
  }


}

class TextFieldWithDynamicColor extends StatefulWidget {
  final SendMessageCallback sendMessage;
  final String path;
  final String matchUID;
  final FocusNode focusNode;

  const TextFieldWithDynamicColor({super.key, required this.sendMessage, required this.path, required, required this.matchUID, required this.focusNode});
  @override
  TextFieldWithDynamicColorState createState() => TextFieldWithDynamicColorState();
}

class TextFieldWithDynamicColorState extends State<TextFieldWithDynamicColor> {
  TextEditingController messageController = TextEditingController();
  Color containerColor = Colors.grey;
  String imagePath = "lib/images/send-icon-disabled.png";
  
  @override
  void initState() {
    super.initState();
    messageController.addListener(() {
      setState(() {
        // Change color to enabled when text is available
        if (messageController.text.trim().isNotEmpty) {
          imagePath = "lib/images/send-icon-enabled.png";
          containerColor = ReuseableColors.primaryColor;

        // Change color to disable when text is not there or are just some spaces
        } else {
          imagePath = "lib/images/send-icon-disabled.png";
          containerColor = Colors.grey;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return newTextField(sendMessage: widget.sendMessage, messageController: messageController, containerColor: containerColor, imagePath: imagePath, path: widget.path, matchUID: widget.matchUID, context: context, focusNode: widget.focusNode);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}

Widget newTextField({required BuildContext context, required SendMessageCallback sendMessage, required TextEditingController messageController, required Color containerColor, required String imagePath, required String path, required String matchUID, required FocusNode focusNode}) {
  return Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor
      ),
      child: Row(
        children: [
          Expanded( 
            child: TextField(
              controller: messageController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintStyle: GoogleFonts.poppins(),
                
                fillColor: Theme.of(context).focusColor, // Fill Color
                filled: true,
                hintText: 'Aa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor), // Border color when not focused
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor), // Border color when focused
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              ),
              style: GoogleFonts.poppins( // Apply Google Fonts to input text
                fontSize: 16.0,
                fontWeight: FontWeight.w500
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

                UserValues.shouldLoad = false;

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

Future popupMatchDetails(BuildContext context, Map value, String key) {
  chatUserDetails["chatUID"] = key;
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
          }
          else {
              Map matchUserData = snapshot.data["UserDetails"];
              List imageUserData = snapshot.data["ImageDetails"];
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: popupHeight, 
                      color: Colors.transparent,
                      child: SingleChildScrollView(
                        // Wrap the content in a SingleChildScrollView
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Match user userImage1
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F$key%2F${imageUserData[1]}?alt=media&token",
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

                            SizedBox(height: 5,),

                            // Match user tags
                            IntrinsicHeight(
                              child: Material(
                                child: aboutMeAndTags(data: matchUserData, context),
                                color: Colors.transparent,
                              ),
                            ),

                            SizedBox(height: 5,),

                            // Match user userImage1
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                height: 700,
                                color: Color(0xFFD9D9D9),
                                child: CachedNetworkImage(
                                  imageUrl: "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F$key%2F${imageUserData[2]}?alt=media&token",
                                  height: popupHeight,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 5,),

                            //Match user location or stream details
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Material(
                                child: fromOrStreamDetails(buttonsNeeded: false, candidateDetails: matchUserData),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
              );
            }
          }
      );
    },
  );

}
