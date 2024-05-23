// ignore_for_file: prefer_const_constructors

import "package:demo/api/api_calls.dart";
import "package:demo/colors.dart";
import "package:demo/main_page.dart";
import "package:demo/pages/login_page/login_page.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import "package:flutter/services.dart";
import "assets/firebase_options.dart";
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async{
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: reuseableColors.secondaryColor,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: reuseableColors.secondaryColor
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    // Set androidProvider to `AndroidProvider.debug`
    androidProvider: AndroidProvider.debug,
  );
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white, 
      ),
      home: Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              final user = snapshot.data;
              if (user != null) {
                if (user.emailVerified) {
                  if (userValues.cookieValue != null){
                    return mainPage();
                  }
                  return FutureBuilder<String>(
                    future: ApiCalls.fetchCookieDoggie(),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Scaffold(
                          backgroundColor: Color.fromRGBO(12, 25, 44, 1),
                          body: Center(child: CircularProgressIndicator(),),
                        );
                      } else {
                        return mainPage();
                      }
                    },
                  );
                } 
                else {
                  return FutureBuilder<String>(
                    future: ApiCalls.fetchCookieDoggie(),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Scaffold(
                          backgroundColor: Color.fromRGBO(12, 25, 44, 1),
                          body: Center(child: CircularProgressIndicator(),),
                        );
                      } else {
                        return mainPage();
                      }
                    },
                  );
                }
              } else {
                return LoginPage();
              }
            }
          },
        ),
      ),
    );
  }
}

