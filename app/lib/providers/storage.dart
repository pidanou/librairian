import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:librairian/models/storage.dart' as st;
import 'package:librairian/providers/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

part 'storage.g.dart';

@riverpod
class Storage extends _$Storage {
  @override
  Future<List<st.Storage>> build() async {
    String url;
    url = 'http://localhost:8080/api/v1/storage';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {"Authorization": "Bearer $token"};

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map<st.Storage>((json) => st.Storage.fromJson(json))
            .toList();
      } else {
        print("Erreur HTTP getting all storages : ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
    return Future.value([]);
  }

  Future<void> delete(String id) async {
    String url;
    url = 'http://localhost:8080/api/v1/storage/$id';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {"Authorization": "Bearer $token"};

    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        state = AsyncValue.data(
            state.value!.where((item) => item.id != id).toList());
      } else {
        print("Erreur HTTP getting all storages : ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
}

@riverpod
class DefaultStorage extends _$DefaultStorage {
  @override
  st.Storage? build() {
    final prefs = ref.read(sharedPreferencesProvider);

    final storageID = prefs.getString("storage_id");
    if (storageID == null) {
      return null;
    }

    final storages = ref.watch(storageProvider);
    if (storages is AsyncLoading || storages is AsyncError) {
      return null;
    }
    if (storages.value?.isEmpty ?? true) {
      return null;
    }
    final storageList =
        storages.value!.where((device) => device.id == storageID).toList();
    if (storageList.isEmpty) {
      return null;
    }
    return storageList.first;
  }

  void set(st.Storage s) {
    state = s;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString('storage_id', s.id ?? '');
  }
}
