// ignore_for_file: prefer_const_constructors

import 'package:demo/colors.dart';
import 'package:demo/elements/home_elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color.fromRGBO(12, 25, 44, 1),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color.fromRGBO(12, 25, 44, 1)
  ));
  runApp(const LoginPage());
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isIconVisible = true;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: reuseableColors.secondaryColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: reuseableColors.secondaryColor
      ),
      child: Scaffold(
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
      
                joinTodayButton(context),
      
                const SizedBox(height: 60),
      
                // Terms and Conditions
      
                termsAndConditions(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
