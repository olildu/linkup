import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linkup/shared_ui/constants/colors.dart';

class BuildPicker extends StatefulWidget {
  final FixedExtentScrollController controller;
  final List<String> items;
  final Function(int) onSelectedItemChanged;
  final double dividerGap;
  final int? selectedIndex;

  const BuildPicker({
    super.key,
    required this.controller,
    required this.items,
    required this.onSelectedItemChanged,
    this.selectedIndex,
    this.dividerGap = 0.25,
  });

  @override
  State<BuildPicker> createState() => _BuildPickerState();
}

class _BuildPickerState extends State<BuildPicker> {
  late int _currentSelectedIndex;

  @override
  void initState() {
    super.initState();
    final defaultIndex = widget.selectedIndex ?? (widget.items.length ~/ 2);
    _currentSelectedIndex = defaultIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.controller.hasClients) {
        widget.controller.jumpToItem(_currentSelectedIndex);
      }
    });
  }

  @override
  void didUpdateWidget(covariant BuildPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex &&
        widget.selectedIndex != null) {
      _currentSelectedIndex = widget.selectedIndex!;
      widget.controller.jumpToItem(_currentSelectedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListWheelScrollView.useDelegate(
          controller: widget.controller,
          itemExtent: 80.h,
          physics: const FixedExtentScrollPhysics(),
          diameterRatio: 2,
          perspective: 0.0001,
          onSelectedItemChanged: (index) {
            setState(() {
              _currentSelectedIndex = index;
            });
            widget.onSelectedItemChanged(index);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (index < 0 || index >= widget.items.length) return null;
              return Center(
                child: Text(
                  widget.items[index],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: _currentSelectedIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _currentSelectedIndex == index
                        ? Theme.of(context).colorScheme.onSurface
                        : AppColors.notSelected,
                  ),
                ),
              );
            },
            childCount: widget.items.length,
          ),
        ),

        // Top Divider
        Align(
          alignment: Alignment(0, -(widget.dividerGap)),
          child: Container(
            height: 2.5.h,
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(1.5.r),
            ),
          ),
        ),

        // Bottom Divider
        Align(
          alignment: Alignment(0, widget.dividerGap),
          child: Container(
            height: 2.5.h,
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(1.5.r),
            ),
          ),
        ),
      ],
    );
  }
}
