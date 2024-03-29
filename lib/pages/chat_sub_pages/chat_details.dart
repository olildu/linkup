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
  late OverlayEntry _overlayEntry;

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

  void initState() {
    super.initState();
    _overlayEntry = _createOverlayEntry();
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _overlayEntry.remove();
                },
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              top: 120,
              bottom: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: const Color(0xFF193046),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 700,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20),
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.image, size: 70),
                          ),
                        ),
                        Container(
                          height: 200,
                        ),
                        Container(
                          height: 700,
                          color: const Color(0xFFD9D9D9),
                          child: const Center(
                            child: Icon(Icons.image, size: 70),
                          ),
                        ),
                        Container(
                          height: 200,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleOverlay() {
    Overlay.of(context)?.insert(_overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_overlayEntry.mounted) {
          _overlayEntry.remove();
          return false; // Returning false prevents closing the app
        }
        return true; // Returning true allows closing the app
      },
      child: Scaffold(

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
        title: GestureDetector(
          onTap: () {
            _toggleOverlay();
          },
          child: Transform.translate(
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
        ),
        actions: [
          ActionWidget()
        ],

      ),
      body: Stack(
        children: [
          MessageContent(_messages),

          TextFieldWithDynamicColor(sendMessage: _addMessage),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
