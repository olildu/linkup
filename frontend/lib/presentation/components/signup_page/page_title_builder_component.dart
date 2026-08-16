import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/presentation/constants/colors.dart';

class PageTitle extends StatelessWidget {
  final String inputText;
  final dynamic highlightWord;
  final String? subText;
  final double fontSize;
  final Color? textColor;

  const PageTitle({
    super.key,
    required this.inputText,
    required this.highlightWord,
    this.subText,
    this.fontSize = 31,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.displayLarge?.copyWith(
      fontSize: fontSize.sp,
      fontWeight: FontWeight.bold,
      color: textColor ?? Theme.of(context).colorScheme.onSurface,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: baseStyle,
            children: _buildTextSpans(inputText, highlightWord, context),
          ),
        ),
        Gap(20.h),
        if (subText != null)
          Text(
            subText!,
            style: AppTextStyles.subtitle(context)?.copyWith(
              fontSize: (fontSize / 2).sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        Gap(20.h),
      ],
    );
  }

  List<TextSpan> _buildTextSpans(
    String text,
    dynamic highlightWord,
    BuildContext context,
  ) {
    final highlightWords = highlightWord is List
        ? highlightWord.map((e) => e.toString().toLowerCase()).toList()
        : [highlightWord.toString().toLowerCase()];

    final spans = <TextSpan>[];
    final lines = text.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final regExp = RegExp(r"[\w'-]+|[^\w\s]");
      final matches = regExp.allMatches(line);

      for (final match in matches) {
        final part = match.group(0)!;
        final isHighlighted = highlightWords.any(
          (word) => part.toLowerCase() == word,
        );

        spans.add(
          TextSpan(
            text: '$part ',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: isHighlighted
                  ? AppColors.primary
                  : textColor ?? Theme.of(context).colorScheme.onSurface,
              fontWeight: isHighlighted ? FontWeight.w900 : FontWeight.normal,
            ),
          ),
        );
      }

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }
}
