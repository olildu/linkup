// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, sort_child_properties_last
import 'dart:async';

import 'package:demo/api/api_calls.dart';
import 'package:demo/pages/chat_sub_pages/chat_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

Color primaryColor = Color(0xFF0C192C);

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

      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {
          flashColor = const Color.fromARGB(0, 219, 219, 219); 
        });
        
        Future.delayed(Duration(), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailsPage(appBarTitle: "Name${widget.index}", imageUrl: "lib/images/user.png"),
            ),
          );
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

Widget matchedUser(){
  // Get matched users list form API
  ApiCalls.GetMatchedUsers();

  return SizedBox(
    height: 100, // Adjust the height as needed
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < 10; i++)
          matchedUsersImages()
        ],
      ),
    ),
  );
}

Widget matchedUsersImages(){
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Container(
      width: 75,
      height: 75, 
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset("lib/images/profile.png"),
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

class TextFieldWithDynamicColor extends StatefulWidget {
  final SendMessageCallback sendMessage;
  TextFieldWithDynamicColor({required this.sendMessage});
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
          containerColor = primaryColor;
        } else {
          imagePath = "lib/images/send-icon-disabled.png";
          containerColor = Colors.grey;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return NewTextField(sendMessage: widget.sendMessage, messageController: messageController, containerColor: containerColor, imagePath: imagePath);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}

Widget NewTextField({required SendMessageCallback sendMessage, required TextEditingController messageController, required Color containerColor, required String imagePath}) {
  return Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    child: Container(
      padding: EdgeInsets.all(10),
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