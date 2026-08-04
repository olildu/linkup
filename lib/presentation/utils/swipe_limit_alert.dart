import 'package:flutter/material.dart';
import 'package:linkup/presentation/components/common/confirmation_dialog_builder.dart';

void showSwipeLimitAlert(BuildContext context) {
  ConfirmationDialogBuilder.show<void>(
    context,
    ConfirmationDialogBuilder(
      icon: Icons.favorite_border_rounded,
      title: 'Out of Likes for Today',
      message: "You've used all your likes for today. Come back tomorrow for more matches!",
      cancelText: 'Got It',
    ),
  );
}
