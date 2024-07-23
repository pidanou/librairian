import "package:flutter/material.dart";

class CustomChipDecorationThemeData {
  static ChipThemeData all() {
    return const ChipThemeData(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
    );
  }
}
