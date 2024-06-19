import 'package:linkup/colors/colors.dart';
import 'package:linkup/api/api_calls.dart';
import 'package:linkup/elements/about_me_edit_elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EditAboutMe extends StatefulWidget {
  final int counter;
  final int progressTrackerValue;
  final Map userData;
  const EditAboutMe({super.key, required this.counter, required this.progressTrackerValue, required this.userData});

  @override
  State<EditAboutMe> createState() => EditAboutMeState();
}

class EditAboutMeState extends State<EditAboutMe> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _progressTrackerValue;
  late int _counter;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _counter = widget.counter;
    _progressTrackerValue = widget.progressTrackerValue; 
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    setState(() {
      if (_counter != 8){
      _counter++;
      _progressTrackerValue += 40;
      }
      else{
        Navigator.of(context).pop();
      }

    });
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.close_rounded, size: 25),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              ProgressTracker(value: _progressTrackerValue.toDouble()),
              if (_counter == 1)
                Animate(
                  autoPlay: false,
                  child: HeightContainer(heightValue: widget.userData["height"].toString()),
                ).slideX(end: -0.2).fadeOut(duration: const Duration(milliseconds: 100)),
              if (_counter == 2)
                Animate(
                  controller: _controller,
                  child: DrinkingContainer(onOptionSelected: _startAnimation),
                ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
              if (_counter == 3)
                Animate(
                  controller: _controller,
                  onComplete: (controller) {
                    setState(() {
                      _counter = 4; 
                    });
                  },
                  child: const DrinkingContainer(),
                ).slideX(begin: 0.0, end: -0.2, duration: const Duration(milliseconds: 100), curve: Curves.easeIn).fadeOut(duration: const Duration(milliseconds: 100)),
              if (_counter == 4)
                Animate(
                  controller: _controller,
                  child: SmokingContainer(onOptionSelected: _startAnimation),
                ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
              if (_counter == 5)
                Animate(
                  controller: _controller,
                  delay: const Duration(microseconds: 100),
                  onComplete: (controller) {
                    setState(() {
                      _counter = 6;
                    });
                  },
                  child: const SmokingContainer(),
                ).slideX(begin: 0.0, end: -0.2, duration: const Duration(milliseconds: 100), curve: Curves.easeIn).fadeOut(duration: const Duration(milliseconds: 100)),
              if (_counter == 6)
                Animate(
                  controller: _controller,
                  child: LookingForContainer(onOptionSelected: _startAnimation),
                ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
              if (_counter == 7)
                Animate(
                  controller: _controller,
                  delay: const Duration(microseconds: 100),
                  onComplete: (controller) {
                    setState(() {
                      _counter = 8;
                    });
                  },
                  child: const LookingForContainer(),
                ).slideX(begin: 0.0, end: -0.2, duration: const Duration(milliseconds: 200), curve: Curves.easeIn).fadeOut(duration: const Duration(milliseconds: 100)),
              if (_counter == 8)
                Animate(
                  delay: const Duration(microseconds: 100),
                  controller: _controller,
                  child: ReligionContainer(onOptionSelected: _startAnimation),
                ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
            ],
          ),
        ),
      ),
      floatingActionButton: _counter == 1
        ? FloatingActionButton(
            onPressed: () {
              _startAnimation();
              ApiCalls.uploadUserTagData(userDataTags);
              // Call your second function here
              // Example: secondFunction();
            },
            shape: const CircleBorder(),
            backgroundColor: ReuseableColors.accentColor,
            child: const Icon(Icons.done_rounded, color: Colors.white),
          )
      : null,
    );
  }
}
