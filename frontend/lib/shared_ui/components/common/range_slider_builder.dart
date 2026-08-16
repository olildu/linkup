import 'package:flutter/material.dart';
import 'package:linkup/shared_ui/constants/colors.dart';

class RangeSliderBuilder extends StatefulWidget {
  final RangeValues values;
  final double min;
  final double max;
  final RangeLabels? labels;
  final int? divisions;
  final ValueChanged<RangeValues> onChanged;

  const RangeSliderBuilder({
    super.key,
    required this.values,
    required this.min,
    required this.max,
    this.labels,
    this.divisions,
    required this.onChanged,
  });

  @override
  State<RangeSliderBuilder> createState() => _RangeSliderBuilder();
}

class _RangeSliderBuilder extends State<RangeSliderBuilder> {
  late RangeValues _currentValues;

  @override
  void initState() {
    super.initState();
    _currentValues = widget.values;
  }

  @override
  Widget build(BuildContext context) {
    Color mainColor = AppColors.primary;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: mainColor,
        inactiveTrackColor: mainColor.withValues(alpha: 0.3),
        thumbColor: mainColor,
        overlayColor: mainColor.withValues(alpha: 0.2),
        rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
        rangeThumbShape: const RoundRangeSliderThumbShape(
          enabledThumbRadius: 10,
        ),
        rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
        valueIndicatorColor: mainColor,
      ),
      child: RangeSlider(
        values: _currentValues,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        labels:
            widget.labels ??
            RangeLabels(
              _currentValues.start.round().toString(),
              _currentValues.end.round().toString(),
            ),
        onChanged: (newValues) {
          setState(() {
            _currentValues = newValues;
          });
          widget.onChanged(newValues);
        },
      ),
    );
  }
}
