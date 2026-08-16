import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/shared_ui/constants/colors.dart';
import 'package:linkup/shared_ui/theme/app_radius.dart';

class TextInputField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback? toggleObscure;
  final bool hasError;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;

  const TextInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.toggleObscure,
    this.hasError = false,
    this.keyboardType,
    this.autofillHints,
  });

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = widget.hasError
        ? colorScheme.error
        : colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: colorScheme.onSurface),
        ),
        Gap(8.h),
        TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          autofillHints: widget.autofillHints,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(
                color: widget.hasError
                    ? colorScheme.error
                    : colorScheme.primary,
              ),
            ),
            suffixIcon: widget.toggleObscure != null
                ? IconButton(
                    icon: Icon(
                      widget.obscureText
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.notSelected,
                    ),
                    onPressed: widget.toggleObscure,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
