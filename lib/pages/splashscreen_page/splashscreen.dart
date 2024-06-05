import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:linkup/colors/colors.dart';
import 'package:linkup/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  late String videoUrl;  
  late VideoPlayerController _controller;

  @override
  void initState(){
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/animation_with_reverse.mp4')
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
        systemNavigationBarColor: reuseableColors.secondaryColor,
        statusBarColor: reuseableColors.secondaryColor,
      ),
      child: Scaffold(
        backgroundColor: reuseableColors.secondaryColor,
        body: AnimatedSplashScreen(
          backgroundColor: reuseableColors.secondaryColor,
          splash: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          ),
          nextScreen: const mainPage(),
        ),
      ),
    );
  }
}