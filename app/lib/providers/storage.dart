import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:librairian/models/storage.dart' as st;
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
}

@riverpod
List<st.Storage> device(DeviceRef ref) {
  // "Ref" can be used here to read other providers
  final storages = ref.watch(storageProvider);
  if (storages.value == null) {
    return [];
  }
  return storages.value!.where((storage) => storage.type == "Device").toList();
}
