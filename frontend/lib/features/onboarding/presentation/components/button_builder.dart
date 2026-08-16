import 'package:flutter/material.dart';
import 'package:linkup/shared_ui/constants/colors.dart';

class ButtonBuilder extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isLoading;
  // Semantic variant — applies error colorScheme styling without raw Color params
  final bool isDestructive;

  const ButtonBuilder({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final ButtonStyle? destructiveStyle = isDestructive
        ? ElevatedButton.styleFrom(
            backgroundColor: colorScheme.errorContainer,
            foregroundColor: colorScheme.error,
          )
        : null;

    return ElevatedButton(
      style: destructiveStyle,
      onPressed: isEnabled && !isLoading ? onPressed : null,
      child: isLoading
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isDestructive ? colorScheme.error : AppColors.whiteText,
              ),
            )
          : Text(text),
    );
  }
}
