import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomOverlay extends StatefulWidget {
  final String text;
  final Widget? iconOrLoader;
  final Color? backgroundColor;
  final Color? textColor;
  final Size? iconSize;

  const CustomOverlay({super.key, required this.text, this.iconOrLoader, this.backgroundColor, this.textColor, this.iconSize});

  @override
  State<CustomOverlay> createState() => _CustomOverlayState();
}

class _CustomOverlayState extends State<CustomOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final txtColor = widget.textColor ?? Theme.of(context).colorScheme.onSurface;
    final iconSize = widget.iconSize ?? Size(48.w, 48.w);

    return WillPopScope(
      onWillPop: () async => false,
      child: FadeTransition(
        opacity: _fadeIn,
        child: Scaffold(
          backgroundColor: bgColor,
          body: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: iconSize.width,
                    height: iconSize.height,
                    child: widget.iconOrLoader ?? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(txtColor), strokeWidth: 4.w),
                  ),

                  Gap(widget.iconOrLoader != null ? 0 : 40.h),

                  Text(
                    widget.text,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp, color: txtColor, fontWeight: FontWeight.w600, letterSpacing: 1.2.w),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
