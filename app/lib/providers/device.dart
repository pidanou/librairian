import 'package:librairian/models/storage.dart' as st;
import 'package:librairian/providers/shared_preferences.dart';
import 'package:librairian/providers/storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device.g.dart';

@riverpod
class CurrentDevice extends _$CurrentDevice {
  @override
  st.Storage? build() {
    final prefs = ref.read(sharedPreferencesProvider);

    final deviceID = prefs.getString("device_id");
    if (deviceID == null) {
      return null;
    }

    final devices = ref.watch(deviceProvider);
    if (devices.isEmpty) {
      return null;
    }
    final deviceList =
        devices.where((device) => device.id == deviceID).toList();
    if (deviceList.isEmpty) {
      return null;
    }
    return deviceList.first;
  }

  void set(st.Storage s) {
    state = s;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString('device_id', s.id ?? '');
  }
}
