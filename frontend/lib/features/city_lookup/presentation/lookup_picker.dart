import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:linkup/features/city_lookup/domain/search_cities_use_case.dart';
import 'package:linkup/features/onboarding/presentation/components/option_builder.dart';
import 'package:linkup/features/onboarding/presentation/components/text_input_builder_component.dart';
import 'package:linkup/shared_ui/utils/debouncer_class.dart';

/// A generic lookup/search picker widget.
/// Provide a list of `items` and an `onChanged` callback.
class LookupPicker extends StatefulWidget {
  final List<String> items;
  final Function(String) onChanged;
  final String label;
  final String placeHolder;
  final String? initialValue;

  const LookupPicker({
    super.key,
    required this.items,
    required this.onChanged,
    this.label = 'Search',
    this.placeHolder = 'Search',
    this.initialValue,
  });

  @override
  State<LookupPicker> createState() => _LookupPickerState();
}

class _LookupPickerState extends State<LookupPicker> {
  final _debouncer = Debouncer(milliseconds: 400);
  late final TextEditingController _controller;
  late List<String> _searchResults;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _searchResults = widget.items;
  }

  void _onSearchChanged(String val) {
    if (val.trim().isEmpty) {
      setState(() => _searchResults = widget.items);
    } else {
      _debouncer.run(() async {
        try {
          // If this is the city lookup context, attempt remote search.
          if (widget.label.toLowerCase().contains('city')) {
            final cities = await GetIt.instance<SearchCitiesUseCase>()(val);
            if (mounted) setState(() => _searchResults = cities);
            return;
          }

          // For local lists, filter client-side.
          final filtered = widget.items
              .where((item) => item.toLowerCase().contains(val.toLowerCase()))
              .toList();
          if (mounted) setState(() => _searchResults = filtered);
        } catch (_) {
          if (mounted) setState(() => _searchResults = []);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextInput(
          label: widget.label,
          placeHolder: widget.placeHolder,
          controller: _controller,
          onChanged: _onSearchChanged,
        ),

        Gap(30.h),

        Expanded(
          child: SingleChildScrollView(
            child: OptionBuilder(
              options: _searchResults,
              textSize: 13,
              onChanged: (val) {
                _controller.text = val;
                widget.onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
