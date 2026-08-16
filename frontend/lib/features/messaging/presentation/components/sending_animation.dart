import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SendingAnimation extends StatefulWidget {
  const SendingAnimation({super.key});

  @override
  State<SendingAnimation> createState() => _SendingAnimationState();
}

class _SendingAnimationState extends State<SendingAnimation> {
  bool _forward = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: _forward ? 0.5 : 1.0, end: _forward ? 1.0 : 0.5),
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
        builder: (context, value, child) =>
            Opacity(opacity: value, child: child),
        onEnd: () {
          setState(() {
            _forward = !_forward;
          });
        },
        child: Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
