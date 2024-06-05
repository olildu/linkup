// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:linkup/elements/chat_elements/elements.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  dynamic Userdata;

  @override
  void initState() {
    super.initState();
    print("Chat Page");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Que Title
            matchQueTitle(),
    
            // Matches Que
            matchedUsers(),
    
            SizedBox(height: 10),

            // Chats Title (The smaller version)
            chatTitle(),
    
            // Chat Widgets
            SizedBox(height: 5),
    
            chatDetailsChatPage(),
          ],
        ),
      ),
    );
  }
}
