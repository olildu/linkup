import "package:demo/api/api_calls.dart";
import "package:demo/colors/colors.dart";
import "package:demo/pages/login_page/login_page.dart";
import "package:demo/pages/providers/provider.dart";
import "package:demo/pages/splashscreen_page/splashscreen.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "assets/firebase_options.dart";
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async{
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: reuseableColors.secondaryColor,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: reuseableColors.secondaryColor
  ));
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize firebase options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize firebase app check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  // Initialize firebase fCMToken
  await firebaseCalls().initNotifications(); 
  
  // Runs app with the provider call
  runApp(
    ChangeNotifierProvider(create: (context) => ThemeProvider(), child: MyApp())
  );
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool didFunctionRun = false;

  Widget build(BuildContext context) {
    // Check for any saved user preference in the localStorage and reflects accordingly
    void getDarkThemeValue() async{
      if (didFunctionRun){
        return;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? localDarkThemeValue = await prefs.getBool('darkTheme');

      if (localDarkThemeValue != null){
        userValues.darkTheme = localDarkThemeValue;
        if (localDarkThemeValue == false){
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        }
        didFunctionRun = true;
      }
    }
    getDarkThemeValue();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
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
                    return splashScreen();
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
                        return splashScreen();
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
                        return splashScreen();
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

