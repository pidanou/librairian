import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale.g.dart';

@riverpod
class LocaleState extends _$LocaleState {
  @override
  Locale build() {
    return const Locale('en');
  }

  set(Locale value) {
    state = value;
  }
}
