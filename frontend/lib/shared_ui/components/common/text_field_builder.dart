import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linkup/shared_ui/constants/colors.dart';

class TextFieldBuilder extends StatefulWidget {
  final String hintText;
  final InputBorder? border;
  final int maxLines;
  final String initialValue;
  final Function(String)? onChanged;

  TextFieldBuilder({
    super.key,
    required this.hintText,
    this.maxLines = 5,
    InputBorder? border,
    this.initialValue = '',
    this.onChanged,
  }) : border =
           border ??
           OutlineInputBorder(
             borderRadius: const BorderRadius.all(Radius.circular(10)),
             borderSide: BorderSide(color: AppColors.notSelected),
           );

  @override
  State<TextFieldBuilder> createState() => _TextFieldBuilderState();
}

class _TextFieldBuilderState extends State<TextFieldBuilder> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppTextStyles.hint(context)?.copyWith(fontSize: 14.sp),
        border: widget.border,
        focusedBorder: widget.border,
        enabledBorder: widget.border,
      ),
    );
  }
}
