import 'package:demo/elements/about_me_edit_elements/elements.dart';
import 'package:flutter/material.dart';

class edit_about_me extends StatefulWidget {
  const edit_about_me({Key? key}) : super(key: key);

  @override
  State<edit_about_me> createState() => _edit_about_meState();
}

class _edit_about_meState extends State<edit_about_me> {
  bool _moved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.close_rounded, size: 25),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  // Your other widgets such as ProgressTracker()
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned(
                          left: _moved ? 100 : 0,
                          top: 0, // Adjust as needed
                          bottom: 0, // Adjust as needed
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _moved = !_moved;
                              });
                            },
                            child: Center(
                              child: HeightContainer(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
