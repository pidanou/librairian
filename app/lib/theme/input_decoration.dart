import "package:flutter/material.dart";

class CustomInputDecorationTheme {
  static InputDecorationTheme all() {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
