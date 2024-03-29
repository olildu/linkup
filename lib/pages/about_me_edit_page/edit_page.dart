import 'package:demo/elements/about_me_edit_elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class edit_about_me extends StatefulWidget {
  final int counter;
  final int progressTrackerValue;

  const edit_about_me({Key? key, required this.counter, required this.progressTrackerValue}) : super(key: key);

  @override
  State<edit_about_me> createState() => _edit_about_meState();
}

class _edit_about_meState extends State<edit_about_me> with SingleTickerProviderStateMixin {
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
      _counter++;
      _progressTrackerValue += 40;
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
                  controller: _controller,
                  autoPlay: false,
                  child: HeightContainer(context),
                ).slideX(end: -0.2).fadeOut(duration: const Duration(milliseconds: 100)),
              if (_counter == 2)
                Animate(
                  controller: _controller,
                  child: DrinkingContainer(context),
                ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
              if (_counter == 3)
                Animate(
                  controller: _controller,
                  onComplete: (controller) {
                    setState(() {
                      _counter = 4; // Transition to next counter
                    });
                  },
                  child: DrinkingContainer(context),
                ).slideX(begin: 0.0, end: -0.2, duration: const Duration(milliseconds: 100), curve: Curves.easeIn).fadeOut(duration: const Duration(milliseconds: 100)),
              if (_counter == 4)
                Animate(
                  controller: _controller,
                  child: SmokingContainer(context),
                ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
              if (_counter == 5)
                Animate(
                  controller: _controller,
                  delay: Duration(microseconds: 100),
                  onComplete: (controller) {
                    setState(() {
                      _counter = 6;
                    });
                  },
                  child: SmokingContainer(context),
                ).slideX(begin: 0.0, end: -0.2, duration: const Duration(milliseconds: 100), curve: Curves.easeIn).fadeOut(duration: const Duration(milliseconds: 100)),
              if (_counter == 6)
                Animate(
                  controller: _controller,
                  child: LookingForContainer(context),
                ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
              if (_counter == 7)
                Animate(
                  controller: _controller,
                  delay: Duration(microseconds: 100),
                  onComplete: (controller) {
                    setState(() {
                      _counter = 8;
                    });
                  },
                  child: LookingForContainer(context),
                ).slideX(begin: 0.0, end: -0.2, duration: const Duration(milliseconds: 200), curve: Curves.easeIn).fadeOut(duration: const Duration(milliseconds: 100)),
              if (_counter == 8)
                Animate(
                  delay: Duration(microseconds: 100),
                  controller: _controller,
                  child: ReligionContainer(context),
                ).fadeIn(duration: const Duration(milliseconds: 100)).slideX(begin: 0.2, end: 0.0, duration: const Duration(milliseconds: 100), curve: Curves.easeIn),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startAnimation,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
