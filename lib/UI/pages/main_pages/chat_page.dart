// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:linkup/api/api_calls.dart';
import 'package:linkup/UI/elements/chat_elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  dynamic userdata;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
            
            ChatDetailsChatPage(),
          ],
        ),
      ),
    );
  }
}
