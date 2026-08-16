import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/core/utils/calculate_age.dart';
import 'package:linkup/features/onboarding/presentation/components/divider_builder_component.dart';
import 'package:linkup/features/onboarding/presentation/components/picker_builder_component.dart';
import 'package:linkup/shared_ui/constants/colors.dart';

class _Debouncer {
  final int milliseconds;
  Timer? _timer;

  _Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class DatePicker extends StatefulWidget {
  final void Function(DateTime date)? onChanged;
  final DateTime? initialDate;

  const DatePicker({super.key, this.onChanged, this.initialDate});

  @override
  DatePickerState createState() => DatePickerState();
}

class DatePickerState extends State<DatePicker> {
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late Map<String, List<String>> monthDays;
  late List<String> years;
  late int selectedMonthIndex;
  late int selectedDayIndex;
  late int selectedYearIndex;

  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;

  final _Debouncer _monthDebouncer = _Debouncer(milliseconds: 200);
  final _Debouncer _dayDebouncer = _Debouncer(milliseconds: 200);
  final _Debouncer _yearDebouncer = _Debouncer(milliseconds: 200);

  DateTime? _previousSelectedDate;

  DateTime get _maxAllowedDate {
    final currentDate = DateTime.now();
    return DateTime(currentDate.year - 18, currentDate.month, currentDate.day);
  }

  @override
  void initState() {
    super.initState();
    _initializeDatePickers();
  }

  void _initializeDatePickers() {
    final minYear = 1995;
    final maxYear = _maxAllowedDate.year;
    years = List.generate(
      maxYear - minYear + 1,
      (index) => (minYear + index).toString(),
    );

    monthDays = {
      'January': List.generate(31, (index) => (index + 1).toString()),
      'February': List.generate(
        _isLeapYear(maxYear) ? 29 : 28,
        (index) => (index + 1).toString(),
      ),
      'March': List.generate(31, (index) => (index + 1).toString()),
      'April': List.generate(30, (index) => (index + 1).toString()),
      'May': List.generate(31, (index) => (index + 1).toString()),
      'June': List.generate(30, (index) => (index + 1).toString()),
      'July': List.generate(31, (index) => (index + 1).toString()),
      'August': List.generate(31, (index) => (index + 1).toString()),
      'September': List.generate(30, (index) => (index + 1).toString()),
      'October': List.generate(31, (index) => (index + 1).toString()),
      'November': List.generate(30, (index) => (index + 1).toString()),
      'December': List.generate(31, (index) => (index + 1).toString()),
    };

    final initial = widget.initialDate;
    if (initial != null && initial.year >= minYear && initial.year <= maxYear) {
      selectedYearIndex = initial.year - minYear;
      selectedMonthIndex = initial.month - 1;
      selectedDayIndex = initial.day - 1;
    } else {
      selectedYearIndex = (years.length ~/ 2);
      selectedMonthIndex = 5;
      selectedDayIndex = 14;
    }

    _monthController = FixedExtentScrollController(
      initialItem: selectedMonthIndex,
    );
    _dayController = FixedExtentScrollController(initialItem: selectedDayIndex);
    _yearController = FixedExtentScrollController(
      initialItem: selectedYearIndex,
    );

    _callOnChanged();
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
  }

  void _callOnChanged() {
    final selectedDate = DateTime(
      int.parse(years[selectedYearIndex]),
      selectedMonthIndex + 1,
      selectedDayIndex + 1,
    );

    if (_previousSelectedDate != selectedDate) {
      _previousSelectedDate = selectedDate;
      if (widget.onChanged != null) {
        widget.onChanged!(selectedDate);
      }
    }
  }

  void _validateAndCorrectDate() {
    final selectedDate = DateTime(
      int.parse(years[selectedYearIndex]),
      selectedMonthIndex + 1,
      selectedDayIndex + 1,
    );

    if (selectedDate.isAfter(_maxAllowedDate)) {
      selectedYearIndex = years.indexOf(_maxAllowedDate.year.toString());
      selectedMonthIndex = _maxAllowedDate.month - 1;
      selectedDayIndex = _maxAllowedDate.day - 1;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _monthController.jumpToItem(selectedMonthIndex);
          _dayController.jumpToItem(selectedDayIndex);
          _yearController.jumpToItem(selectedYearIndex);
          setState(() {
            _callOnChanged();
          });
        }
      });
    } else {
      _callOnChanged();
    }
  }

  List<String> _getAllowedMonths(int year) {
    if (year == _maxAllowedDate.year) {
      return months.sublist(0, _maxAllowedDate.month);
    }
    return months;
  }

  List<String> _getAllowedDays(String month, int year) {
    var days = monthDays[month]!;

    if (year == _maxAllowedDate.year &&
        months.indexOf(month) == _maxAllowedDate.month - 1) {
      days = days.sublist(0, _maxAllowedDate.day);
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final selectedYear = int.parse(years[selectedYearIndex]);
    final allowedMonths = _getAllowedMonths(selectedYear);
    final selectedMonth = allowedMonths[selectedMonthIndex];
    final daysInMonth = _getAllowedDays(selectedMonth, selectedYear);

    final selectedDate = DateTime(
      selectedYear,
      selectedMonthIndex + 1,
      selectedDayIndex + 1,
    );

    final exactAge = calculateAge(selectedDate);

    if (selectedMonthIndex >= allowedMonths.length) {
      selectedMonthIndex = allowedMonths.length - 1;
      _monthController.jumpToItem(selectedMonthIndex);
    }

    if (selectedMonthIndex >= allowedMonths.length) {
      selectedMonthIndex = allowedMonths.length - 1;
      _monthController.jumpToItem(selectedMonthIndex);
    }

    if (selectedDayIndex >= daysInMonth.length) {
      selectedDayIndex = daysInMonth.length - 1;
      _dayController.jumpToItem(selectedDayIndex);
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: BuildPicker(
                  controller: _monthController,
                  selectedIndex: selectedMonthIndex,
                  items: allowedMonths,
                  onSelectedItemChanged: (index) {
                    _monthDebouncer.run(() {
                      if (mounted) {
                        setState(() {
                          selectedMonthIndex = index;
                          final newDays = _getAllowedDays(
                            allowedMonths[index],
                            selectedYear,
                          );
                          if (selectedDayIndex >= newDays.length) {
                            selectedDayIndex = newDays.length - 1;
                            _dayController.jumpToItem(selectedDayIndex);
                          }
                          _validateAndCorrectDate();
                        });
                      }
                    });
                  },
                ),
              ),

              Expanded(
                child: BuildPicker(
                  controller: _dayController,
                  selectedIndex: selectedDayIndex,
                  items: daysInMonth,
                  onSelectedItemChanged: (index) {
                    _dayDebouncer.run(() {
                      if (mounted) {
                        setState(() {
                          selectedDayIndex = index;
                          _validateAndCorrectDate();
                        });
                      }
                    });
                  },
                ),
              ),

              Expanded(
                flex: 2,
                child: BuildPicker(
                  controller: _yearController,
                  selectedIndex: selectedYearIndex,
                  items: years,
                  onSelectedItemChanged: (index) {
                    _yearDebouncer.run(() {
                      if (mounted) {
                        setState(() {
                          selectedYearIndex = index;
                          final year = int.parse(years[index]);
                          if (allowedMonths[selectedMonthIndex] == 'February') {
                            final isLeap = _isLeapYear(year);
                            monthDays['February'] = List.generate(
                              isLeap ? 29 : 28,
                              (i) => (i + 1).toString(),
                            );
                          }
                          _validateAndCorrectDate();
                        });
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        Gap(20.h),

        buildDivider(
          height: 1.h,
          color: AppColors.notSelected,
          borderRadius: BorderRadius.circular(1.5.r),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 30.w),
            child: Align(
              child: Column(
                children: [
                  Text(
                    'Age $exactAge',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Gap(10.h),
                  Text(
                    "This cannot be changed",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.whiteGreyTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    _monthDebouncer._timer?.cancel();
    _dayDebouncer._timer?.cancel();
    _yearDebouncer._timer?.cancel();
    super.dispose();
  }
}
