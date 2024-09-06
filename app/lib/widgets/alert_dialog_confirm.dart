import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlertDialogConfirm extends ConsumerWidget {
  const AlertDialogConfirm(
      {this.action,
      this.title,
      this.message,
      this.confirmMessage,
      this.icon,
      super.key});

  final Widget? icon;
  final Widget? title;
  final Widget? message;
  final VoidCallback? action;
  final Widget? confirmMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      icon: icon,
      title: title,
      content: message,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            action?.call();
            Navigator.pop(context, true);
          },
          child: confirmMessage ?? const Text('OK'),
        ),
      ],
    );
  }
}
