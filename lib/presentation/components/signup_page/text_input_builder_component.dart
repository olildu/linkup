import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/presentation/constants/colors.dart';

class TextInput extends StatefulWidget {
  final String label;
  final String placeHolder;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const TextInput({
    super.key,
    required this.label,
    this.placeHolder = "",
    this.onChanged,
    this.initialValue,
    this.controller,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  late final TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController =
        widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.subtitle(context)?.copyWith(fontSize: 18.sp),
        ),
        Gap(10.h),
        TextField(
          controller: _internalController,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.placeHolder,
            hintStyle: AppTextStyles.hint(context)?.copyWith(fontSize: 20.sp),
            isDense: true,
            contentPadding: EdgeInsets.only(bottom: 4.h),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.notSelected),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            border: const UnderlineInputBorder(),
          ),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
