import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DefaultError extends StatelessWidget {
  final String? text;
  final VoidCallback? onTap;

  const DefaultError({super.key, this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap ??
          () {
            GoRouter.of(context).go("/");
          },
      child: Text(text ?? 'Error'),
    );
  }
}
