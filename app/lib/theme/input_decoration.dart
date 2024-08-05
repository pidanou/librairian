import "package:flutter/material.dart";

class CustomInputDecorationTheme {
  static InputDecorationTheme all() {
    return InputDecorationTheme(
      contentPadding: const EdgeInsets.all(10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
