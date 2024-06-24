import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:linkup/colors/colors.dart';
import 'package:linkup/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkup/pages/create_profile_page/create_profile_page.dart';
import 'package:linkup/responsive/responsive_layer.dart';
import 'package:video_player/video_player.dart';

import '../../responsive/desktop.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late String videoUrl;  
  late VideoPlayerController _controller;

  @override
  void initState(){
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/animation_with_reverse_backup.mp4')
    ..initialize().then((_) {
      setState(() {});
      _controller.play();
      _controller.setLooping(true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: ReuseableColors.secondaryColor,
        statusBarColor: ReuseableColors.secondaryColor,
      ),
      child: Scaffold(
        backgroundColor: ReuseableColors.secondaryColor,
        body: AnimatedSplashScreen(
          backgroundColor: ReuseableColors.secondaryColor,
          splash: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          ),
          nextScreen: const ResponsiveLayer(
            mobileScaffold: MainPage(),
            desktopScaffold: DesktopUI(),
          )
        ),
      ),
    );
  }
}