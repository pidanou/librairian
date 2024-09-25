import "package:flutter/material.dart";

class CustomInputDecorationTheme {
  static InputDecorationTheme all() {
    return InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.all(10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
