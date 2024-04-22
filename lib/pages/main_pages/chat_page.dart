// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:demo/elements/chat_elements/elements.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Que Title
            matchQueTitle(),
    
            // Matches Que
            matchedUser(context),
    
            SizedBox(height: 20),
            // Chats Title
    
            chatTitle(),
    
            // Chat Widgets
    
            SizedBox(height: 5),
    
            chatDetailsStructure(),
          ],
        ),
      ),
    );
  }
}
