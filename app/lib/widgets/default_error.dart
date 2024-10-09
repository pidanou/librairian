import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      child: Text(text ?? AppLocalizations.of(context)!.error),
    );
  }
}
