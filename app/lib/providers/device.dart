import 'package:librairian/models/storage.dart' as st;
import 'package:librairian/providers/storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'device.g.dart';

@riverpod
class CurrentDevice extends _$CurrentDevice {
  @override
  Future<st.Storage?> build() async {
    final prefs = await SharedPreferences.getInstance();

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

  void set(st.Storage s) async {
    state = AsyncValue.data(s);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_id', s.id ?? '');
  }
}
