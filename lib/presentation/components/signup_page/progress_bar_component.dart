import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linkup/presentation/constants/colors.dart';

class ProgressBarComponent extends StatefulWidget {
  final int currentIndex;
  final int totalSteps;
  final Duration animationDuration;

  const ProgressBarComponent({
    super.key,
    required this.currentIndex,
    this.totalSteps = 10,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<ProgressBarComponent> createState() => _ProgressBarComponentState();
}

class _ProgressBarComponentState extends State<ProgressBarComponent>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  // int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.totalSteps,
      (index) =>
          AnimationController(vsync: this, duration: widget.animationDuration),
    );
    _animations = _controllers
        .map(
          (controller) =>
              CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic),
        )
        .toList();
    _animateBars();
  }

  @override
  void didUpdateWidget(ProgressBarComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // _previousIndex = oldWidget.currentIndex;
      _animateBars();
    }
  }

  void _animateBars() {
    for (int i = 0; i < widget.totalSteps; i++) {
      if (i <= widget.currentIndex) {
        _controllers[i].forward();
      } else {
        _controllers[i].reverse();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: .end,
        crossAxisAlignment: .end,
        children: List.generate(widget.totalSteps, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Expanded(
                child: Container(
                  height: 15.h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: _getAnimatedColor(index, _animations[index].value),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Color _getAnimatedColor(int index, double animationValue) {
    if (index < widget.currentIndex) {
      return AppColors.primary;
    } else if (index == widget.currentIndex) {
      return Color.lerp(
        AppColors.notSelected,
        AppColors.primary,
        animationValue,
      )!;
    } else {
      return AppColors.notSelected;
    }
  }
}
