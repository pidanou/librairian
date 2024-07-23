import 'package:flutter/material.dart';

class ChatPrompt extends StatelessWidget {
  const ChatPrompt({super.key, required this.prompt});
  final String prompt;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 0,
      child: Padding(padding: const EdgeInsets.all(10), child: Text(prompt)),
    );
  }
}
