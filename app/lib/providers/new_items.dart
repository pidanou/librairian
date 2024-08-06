import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:librairian/models/item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

part 'new_items.g.dart';

@riverpod
class NewItems extends _$NewItems {
  @override
  List<Item> build() {
    return [];
  }

  void add(List<Item> value) {
    state = [...state, ...value];
  }

  void set(List<Item> value) {
    state = value;
  }

  Item? getAt(int index) {
    if (index < 0 || index >= state.length) {
      return null;
    }
    return state[index];
  }

  void editAt(int index, Item value) {
    if (index < 0 || index >= state.length) {
      return;
    }
    state = [...state.sublist(0, index), value, ...state.sublist(index + 1)];
  }

  // Save a file and returns true if successful, if error returns false
  Future<bool> saveItem(int i) async {
    Item file = state[i];
    String url;
    url = '${const String.fromEnvironment('API_URL')}/api/v1/items';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };
    file.userId = Supabase.instance.client.auth.currentUser!.id;
    for (var sl in file.storageLocations ?? []) {
      sl.userId = Supabase.instance.client.auth.currentUser!.id;
      sl.storage?.userId = Supabase.instance.client.auth.currentUser!.id;
    }

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode([file]));
      if (response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data["errors"]
            .map<Item>((data) => Item.fromJson(data))
            .toList()
            .isEmpty) {
          state = [...state.sublist(0, i), ...state.sublist(i + 1)];
          return true;
        }
        return false;
      } else {
        print("Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Save all files, returns a list of errors
  Future<List<Item>> saveAll() async {
    String url;
    url = '${const String.fromEnvironment('API_URL')}/api/v1/items';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };
    List<Item> files = [];
    for (var file in state) {
      file.userId = Supabase.instance.client.auth.currentUser!.id;
      for (var sl in file.storageLocations ?? []) {
        sl.userId = Supabase.instance.client.auth.currentUser!.id;
        sl.storage.userId = Supabase.instance.client.auth.currentUser!.id;
      }
      files.add(file);
    }

    List<Item> errors = [];
    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(files));
      if (response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        errors =
            data["errors"].map<Item>((data) => Item.fromJson(data)).toList();
      } else {
        print("Error: ${response.statusCode}");
        return state;
      }
    } catch (e) {
      print(e);
      return state;
    }
    state = errors;
    return errors;
  }
}
