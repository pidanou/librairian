import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:librairian/models/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageRepository {
  StorageRepository(this.client);
  final http.Client client;

  FutureOr<Storage?> getStorageById(String id) async {
    String url =
        '${const String.fromEnvironment('API_URL')}/api/v1/storage/$id';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        return Storage.fromJson(data);
      } else {
        print("Http error : ${response.body}");
      }
    } catch (e) {
      print("Exception : $e");
      return null;
    }
    return null;
  }
}
