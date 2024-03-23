import 'package:demo/elements/about_me_edit_elements/elements.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Position Demo',
      home: EditAboutMe(),
    );
  }
}

class EditAboutMe extends StatefulWidget {
  @override
  _EditAboutMeState createState() => _EditAboutMeState();
}

class _EditAboutMeState extends State<EditAboutMe> {
  bool _moved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit About Me'),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: _moved ? 100 : 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _moved = !_moved;
                });
              },
              child: HeightContainer(context)
            ),
          ),
        ],
      ),
    );
  }
}
