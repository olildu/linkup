// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:demo/elements/chat_elements/elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late OverlayEntry _overlayEntry;

  @override
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
        body: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Match Que Title
              matchQueTitle(),

              // Matches Que
              GestureDetector(
                onTap: () {
                  _toggleOverlay();
                },
                child: matchedUser(),
              ),

              SizedBox(height: 20),
              // Chats Title

              chatTitle(),

              // Chat Widgets

              SizedBox(height: 5),

              chatDetailsStructure(),
            ],
          ),
        ),
      ),
    );
  }
}
