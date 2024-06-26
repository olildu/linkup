import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/main.dart';
import 'package:linkup/main_page.dart';
import 'package:linkup/pages/create_profile_page/create_profile_page.dart';
import 'package:linkup/responsive/desktop.dart';
import 'package:linkup/responsive/responsive_layer.dart';

class SplashScreenNew extends StatefulWidget {
  final bool createProfile;
  const SplashScreenNew({super.key, this.createProfile = false});

  @override
  State<SplashScreenNew> createState() => _SplashScreenNewState();
}

class _SplashScreenNewState extends State<SplashScreenNew> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool internetStatus = true;
  bool stopAnimation = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );


    moveNextPage(widget.createProfile);
  }

  void listenTillBackOnline(){
    InternetConnection().onStatusChange.listen((event) {
      if (event == InternetStatus.connected){
        print("Online");
        // main();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      }
    });
  }

  Future<void> moveNextPage(bool createProfile) async {
    await _animationController.forward();
    var status = await InternetConnection().internetStatus;

    if (status == InternetStatus.disconnected){
      setState(() {
        internetStatus = false;
      });
      listenTillBackOnline();
      return;
    }else{
      setState((){
        internetStatus = true;
      });
    }

    await ApiCalls.fetchCookieDoggie(widget.createProfile); // If createProfile is true then that is passed else false

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      stopAnimation = true;
    });

    await _animationController.reverse(); // Fade out animation

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ResponsiveLayer(
      mobileScaffold: const MainPage(),
      desktopScaffold: const DesktopUI(),
      createProfilePage: const CreateUserProfile(),
      createProfile: createProfile,
      )),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        statusBarColor: Theme.of(context).colorScheme.surface,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: FadeTransition(
                opacity: _animation,
                child: Image.asset(
                  'assets/logo/logo_transparent.png',
                  width: 200,
                ),
              ),
            ),
            
            if (!internetStatus)...[
              const SizedBox(height: 20,),

              const Center(
                child: Icon(Icons.cloud_off, size: 40,)
              )
            ]
            else...[
              const SizedBox(height: 20,),
              if(!stopAnimation)...[
                const Center(
                  child: CircularProgressIndicator(),
                )
              ]
            ]

          ],
        ),
      ),
    );
  }
}
