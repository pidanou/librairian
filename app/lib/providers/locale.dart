import 'package:flutter/material.dart';
import 'package:librairian/providers/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale.g.dart';

@riverpod
class LocaleState extends _$LocaleState {
  @override
  Locale build() {
    final prefs = ref.read(sharedPreferencesProvider);
    String locale = prefs.getString("locale") ?? "en";
    return Locale(locale);
  }

  set(Locale value) {
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString("locale", value.toString());
  }
}
