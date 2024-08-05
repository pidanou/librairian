import 'package:flutter/material.dart';

class OrderBySelector extends StatelessWidget {
  const OrderBySelector(
      {super.key, required this.options, this.controller, required this.child});
  final List<Widget> options;
  final MenuController? controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: controller,
      menuChildren: options,
      builder: (context, controller, child) {
        return FilledButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context)
                .colorScheme
                .secondary), // Change this color as needed
          ),
          child: child,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
      child: child,
    );
  }
}
