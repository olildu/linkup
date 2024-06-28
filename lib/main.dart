import "package:flutter/foundation.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:in_app_notification/in_app_notification.dart";
import "package:linkup/api/api_calls.dart";
import "package:linkup/api/common_functions.dart";
import "package:linkup/firebase_options.dart";
import "package:linkup/pages/login_page/login_page.dart";
import "package:linkup/pages/providers/theme_provider.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import "package:linkup/pages/splashscreen_page/splashScreen.dart";
import "package:provider/provider.dart";
import "package:shake_flutter/shake_flutter.dart";

void main() async{
  // Initialize env variables
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shakeToReport
  Shake.start('dotenv.env["SHAKE_API_KEY"]'); // API key loaded from here
  Shake.setShakingThreshold(200);

  // Initialize firebase options
  await Firebase.initializeApp(
    name: "linkup",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb){
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
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
    return InAppNotification( // Dependency for inApp notification when user recieves a message in chatPage
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProvider>(context).themeData,
        home: Scaffold(
          body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                );
              } else {
                final user = snapshot.data;
                if (user != null) { // User is logged in 
                  Shake.registerUser(user.uid);
                  // Reload the user data to ensure emailVerified is up-to-date
                  return FutureBuilder(
                    future: user.reload().then((_) => FirebaseAuth.instance.currentUser),
                    builder: (BuildContext context, AsyncSnapshot<User?> reloadSnapshot) {
                      if (reloadSnapshot.connectionState == ConnectionState.waiting) {
                        return  Scaffold(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                        );
                      } else {
                        final reloadedUser = reloadSnapshot.data;
                        if (reloadedUser != null && reloadedUser.emailVerified) {
                          if (UserValues.cookieValue != null) {
                            return const SplashScreenNew();
                          }
                          // future: ApiCalls.fetchCookieDoggie(false), // dont forget this
      
                          return const SplashScreenNew();
                        } 
                        else {
                          return const SplashScreenNew(createProfile : true); // To create profile
                          // return const SplashScreenNewNew(createProfile : true); // To create profile
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

