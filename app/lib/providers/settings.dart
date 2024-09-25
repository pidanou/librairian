import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';

@riverpod
class SelectedSetting extends _$SelectedSetting {
  @override
  String? build() {
    return null;
  }

  void set(String value) {
    state = value;
  }

  clear() {
    state = null;
  }
}
