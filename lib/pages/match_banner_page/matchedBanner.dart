import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:demo/Colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';

class matchedBannerPage extends StatefulWidget {
  final String matchUID;
  final String imageName;

  const matchedBannerPage({Key? key, required this.imageName, required this.matchUID}) : super(key: key);

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
                      // Match Candidate Image Url
                      imageUrl: "https://firebasestorage.googleapis.com/v0/b/mujdating.appspot.com/o/UserImages%2F${widget.matchUID}%2F${widget.imageName}?alt=media&token",
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()), // Placeholder widget while image is loading
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      fit: BoxFit.cover, // Widget to display in case of error loading image
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: reuseableColors.accentColor
                    ),
                    child: Center(child: Text("Continue Swiping", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),)),
                  ),
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