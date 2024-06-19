import "package:in_app_notification/in_app_notification.dart";
import "package:linkup/api/api_calls.dart";
import "package:linkup/api/common_functions.dart";
import "package:linkup/colors/colors.dart";
import "package:linkup/firebase_options.dart";
import "package:linkup/pages/create_profile_page/create_profile_page.dart";
import "package:linkup/pages/login_page/login_page.dart";
import "package:linkup/pages/providers/theme_provider.dart";
import "package:linkup/pages/splashscreen_page/splashscreen.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

void main() async{
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: ReuseableColors.secondaryColor,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: ReuseableColors.secondaryColor
  ));
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize firebase options

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize firebase app check
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug,
  // );
  
  // Initialize firebase fCMToken only if not web
  FirebaseCalls().initNotifications(); 
  
  // Runs app with the provider call
  runApp(
    ChangeNotifierProvider(create: (context) => ThemeProvider(), child: const MyApp())
  );
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Check for any saved user preference in the localStorage and reflects accordingly
    CommonFunction().getDarkThemeValue(context);

    return InAppNotification(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProvider>(context).themeData,
        home: Scaffold(
          body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                final user = snapshot.data;
                if (user != null) {
                  // Reload the user data to ensure emailVerified is up-to-date
                  return FutureBuilder(
                    future: user.reload().then((_) => FirebaseAuth.instance.currentUser),
                    builder: (BuildContext context, AsyncSnapshot<User?> reloadSnapshot) {
                      if (reloadSnapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          backgroundColor: Color.fromRGBO(12, 25, 44, 1),
                          body: Center(child: CircularProgressIndicator()),
                        );
                      } else {
                        final reloadedUser = reloadSnapshot.data;
                        if (reloadedUser != null && reloadedUser.emailVerified) {
                          if (UserValues.cookieValue != null) {
                            return const SplashScreen();
                          }
                          return FutureBuilder<String>(
                            future: ApiCalls.fetchCookieDoggie(false),
                            builder: (BuildContext context, AsyncSnapshot<String> cookieSnapshot) {
                              if (cookieSnapshot.connectionState == ConnectionState.waiting) {
                                return const Scaffold(
                                  backgroundColor: Color.fromRGBO(12, 25, 44, 1),
                                  body: Center(child: CircularProgressIndicator()),
                                );
                              } else {
                                return const SplashScreen();
                              }
                            },
                          );
                        } else {
                          return FutureBuilder<String>(
                            future: ApiCalls.fetchCookieDoggie(true),
                            builder: (BuildContext context, AsyncSnapshot<String> cookieSnapshot) {
                              if (cookieSnapshot.connectionState == ConnectionState.waiting) {
                                return const Scaffold(
                                  backgroundColor: Color.fromRGBO(12, 25, 44, 1),
                                  body: Center(child: CircularProgressIndicator()),
                                );
                              } else {
                                return const createUserProfile();
                              }
                            },
                          );
                        }
                      }
                    },
                  );
                } else {
                  return const LoginPage();
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

