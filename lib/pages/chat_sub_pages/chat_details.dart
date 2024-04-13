// ignore_for_file: prefer_const_constructors, prefer_final_fields, sort_child_properties_last

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo/api/api_calls.dart';
import 'package:demo/api/firebase_calls.dart';
import 'package:demo/elements/chat_elements/elements.dart';
import 'package:demo/Colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
    print(event.snapshot.value);
    
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
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
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
        ActionWidget()
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
    return NewTextField(sendMessage: widget.sendMessage, messageController: messageController, containerColor: containerColor, imagePath: imagePath, path: widget.path, matchUID: widget.matchUID);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}

Widget NewTextField({required SendMessageCallback sendMessage, required TextEditingController messageController, required Color containerColor, required String imagePath, required String path, required String matchUID}) {
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
