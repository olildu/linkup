// ignore_for_file: prefer_const_constructors

import 'package:demo/elements/home_elements/elements.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isIconVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(12, 25, 44, 1),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 90),

              // MUJDating Branding Name

              appTitle(),
              
              SizedBox(height: 100),

              // Images Love and Hands Symbol

              imagesLoveHands(),

              const Spacer(),
              
              // Dating For MUJ Students (SLOGAN)

              appSlogan(),

              SizedBox(height: 10),

              // Join the campus dating community

              infotext(),

              const SizedBox(height: 20),

              // Join Today Button (Login logic make in this widget)

              joinTodayButton(),

              const SizedBox(height: 60),

              // Terms and Conditions

              termsAndConditions(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
