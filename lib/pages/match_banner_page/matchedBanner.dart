import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:demo/Colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class matchedBannerPage extends StatefulWidget {
  const matchedBannerPage({super.key});

  @override
  State<matchedBannerPage> createState() => _matchedBannerPageState();
}

class _matchedBannerPageState extends State<matchedBannerPage> {
  final conffettiController = ConfettiController();
  final audioController = AudioPlayer();

  @override
  void initState(){
    super.initState();
    conffettiController.play();
    Future.delayed(Duration(seconds: 2)).then((value) {
      conffettiController.stop();
    });
    playSound();

  }

  void playSound() async{
    final audioSource = AssetSource('audio/match_sound_effect.mp3');
    await audioController.play(audioSource);
  }

  @override
  void dispose(){
    conffettiController.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    List<Shadow> shadows = [];
    for (int i = -8; i < 0; i++) {
      shadows.add(
        Shadow(
          color: reuseableColors.primaryColor,
          offset: Offset(i.toDouble(), 8),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: reuseableColors.secondaryColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.close, color: Colors.white,)
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  reuseableColors.secondaryColor,
                  reuseableColors.primaryColor,
                ],
              ),
            )
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "IT'S A MATCH!!", 
                  style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white, shadows: shadows)
                ),
                const SizedBox(height: 20,),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 500,
                    width: 300,
                    child: CachedNetworkImage(
                      imageUrl: "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2FQCIG6YCw9HcpLyf5jYHc1yewq6k1%2Fme8.jpg?alt=media&token=d56fbd15-fb1a-4b8f-b80b-f28fe8d3594b",
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()), // Placeholder widget while image is loading
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      fit: BoxFit.cover, // Widget to display in case of error loading image
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: reuseableColors.accentColor
                  ),
                  child: Center(child: Text("Start Chatting", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),)),
                )
              ],
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ConfettiWidget(
                  shouldLoop: false,
                  confettiController: conffettiController,
                  blastDirection: 0-1,
                ),
                ConfettiWidget(
                  shouldLoop: false,
                  confettiController: conffettiController,
                  blastDirection: pi+1,
                ),
              ],
            ),
          ),
      ]
      ),
    );
  }
}