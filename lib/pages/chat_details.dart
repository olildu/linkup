// ignore_for_file: prefer_const_constructors, prefer_final_fields, sort_child_properties_last

import 'package:demo/elements/chat_elements/elements.dart';
import 'package:flutter/material.dart';

class ChatDetailsPage extends StatefulWidget {
  final String appBarTitle;
  final String imageUrl;

  const ChatDetailsPage({super.key, required this.appBarTitle, required this.imageUrl});

  @override
  _ChatDetailsPageState createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  TextEditingController _messageController = TextEditingController();

  List<Map<String, dynamic>> _messages = [
    {"text": "Hello!", "sender": "user1"},
    {"text": "How are you?", "sender": "user2"},
    {"text": "I'm doing well, thank you.", "sender": "user1"},
    {"text": "What about you?", "sender": "user2"},
  ];

  void _addMessage(Map<String, dynamic> message) {
    setState(() {
      _messages.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        title: Transform.translate(
          offset: Offset(-22, 0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(widget.imageUrl),
                radius: 20,
              ),
              SizedBox(width: 10),
              Text(widget.appBarTitle),
            ],
          ),
        ),
        actions: [
          ActionWidget()
        ],

      ),
      body: Stack(
        children: [
          MessageContent(_messages),

          // Message Input Widget (argument passed to add messages typed to the list) 
          TextFieldWithDynamicColor(sendMessage: _addMessage),
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
