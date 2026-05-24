import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linkup/presentation/constants/colors.dart';

class ButtonBuilder extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final bool isFullWidth;
  final EdgeInsetsGeometry padding;
  final bool isEnabled;
  final bool isLoading;

  const ButtonBuilder({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 56,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.whiteTextColor,
    this.borderRadius = 12.0,
    this.isFullWidth = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(color: isEnabled ? backgroundColor : AppColors.notSelected, borderRadius: BorderRadius.circular(borderRadius)),
        child: isLoading
            ? Center(
                child: Transform.scale(scale: 0.7, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(textColor))),
              )
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(borderRadius),
                  onTap: () {
                    if (isEnabled) {
                      onPressed();
                    } else {
                      return;
                    }
                  },
                  child: Padding(
                    padding: padding,
                    child: Center(
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: textColor, fontSize: 16.sp),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
