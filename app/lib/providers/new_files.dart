import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:librairian/models/file.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

part 'new_files.g.dart';

@riverpod
class NewFiles extends _$NewFiles {
  @override
  List<File> build() {
    return [];
  }

  void add(List<File> value) {
    state = [...state, ...value];
  }

  void set(List<File> value) {
    state = value;
  }

  File? getAt(int index) {
    if (index < 0 || index >= state.length) {
      return null;
    }
    return state[index];
  }

  void editAt(int index, File value) {
    if (index < 0 || index >= state.length) {
      return;
    }
    state = [...state.sublist(0, index), value, ...state.sublist(index + 1)];
  }

  // Save a file and returns true if successful, if error returns false
  Future<bool> saveFile(int i) async {
    File file = state[i];
    String url;
    url = 'http://localhost:8080/api/v1/files';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };
    file.userId = Supabase.instance.client.auth.currentUser!.id;
    for (var sl in file.storageLocations ?? []) {
      sl.userId = Supabase.instance.client.auth.currentUser!.id;
      sl.storage.userId = Supabase.instance.client.auth.currentUser!.id;
    }

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode([file]));
      if (response.statusCode < 300) {
        state = [...state.sublist(0, i), ...state.sublist(i + 1)];
        return true;
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
  Future<List<File>> saveAll() async {
    String url;
    url = 'http://localhost:8080/api/v1/files';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };
    List<File> files = [];
    for (var file in state) {
      file.userId = Supabase.instance.client.auth.currentUser!.id;
      for (var sl in file.storageLocations ?? []) {
        sl.userId = Supabase.instance.client.auth.currentUser!.id;
        sl.storage.userId = Supabase.instance.client.auth.currentUser!.id;
      }
      files.add(file);
    }

    List<File> errors = [];
    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(files));
      if (response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        errors =
            data["errors"].map<File>((data) => File.fromJson(data)).toList();
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
