import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/main.dart';
import 'package:linkup/main_page.dart';
import 'package:linkup/UI/pages/create_profile_page/create_profile_page.dart';
import 'package:linkup/UI/responsive/desktop.dart';
import 'package:linkup/UI/responsive/responsive_layer.dart';

class SplashScreenNew extends StatefulWidget {
  final bool createProfile;
  const SplashScreenNew({super.key, this.createProfile = false});

  @override
  State<SplashScreenNew> createState() => _SplashScreenNewState();
}

class _SplashScreenNewState extends State<SplashScreenNew>
    with SingleTickerProviderStateMixin {
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

  void listenTillBackOnline() {
    InternetConnection().onStatusChange.listen((event) {
      if (event == InternetStatus.connected) {
        main();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      }
    });
  }

  Future<void> moveNextPage(bool createProfile) async {
    await _animationController.forward(); // Start fadeIn animation

    var status = await InternetConnection().internetStatus;

    if (status == InternetStatus.disconnected) {
      setState(() {
        internetStatus = false; // Show the cloud disconnected icon
      });
      listenTillBackOnline(); // Listen for connection changes
      return;
    } else {
      setState(() {
        internetStatus = true;
      });
    }

    var result = await FirebaseCalls().getAPIKeys();
    if (result == 1) { // Result 1 means error in getAPIKeys
      setState(() {
        internetStatus = false; // Show the cloud disconnected icon
      });
      listenTillBackOnline(); // Listen for connection changes
      return;
    }

    await ApiCalls.fetchCookieDoggie(widget.createProfile);

    await _animationController.reverse(); // Fade out animation

    Navigator.pushReplacement(
      context,
      // ignore: prefer_const_constructors
      MaterialPageRoute(
          builder: (context) => ResponsiveLayer(
                mobileScaffold: const MainPage(),
                desktopScaffold: const DesktopUI(),
                createProfilePage: const CreateUserProfile(),
                createProfile: widget.createProfile,
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
                  UserValues.darkTheme
                      ? 'assets/logo/logo_transparent.png'
                      : 'assets/logo/logo_transparent_dark.png',
                  width: 200,
                ),
              ),
            ),
            if (!internetStatus) ...[
              const SizedBox(
                height: 20,
              ),
              const Center(
                  child: Icon(
                Icons.cloud_off,
                size: 40,
              ))
            ] else ...[
              const SizedBox(
                height: 30,
              ),
              FadeTransition(
                opacity: _animation,
                child: SizedBox(
                    child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).hintColor,
                  ),
                )),
              )
            ]
          ],
        ),
      ),
    );
  }
}
