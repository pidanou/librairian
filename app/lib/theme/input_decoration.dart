import "package:flutter/material.dart";

class CustomInputDecorationTheme {
  static InputDecorationTheme all() {
    return InputDecorationTheme(
      alignLabelWithHint: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
