import 'dart:convert';

import 'package:librairian/models/item.dart' as im;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:http/http.dart' as http;

part 'item.g.dart';

@riverpod
class Item extends _$Item {
  @override
  Item build() {
    return Item();
  }

  Future<bool> deleteById(String id) async {
    String url = '${const String.fromEnvironment('API_URL')}/api/v1/item/$id';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };
    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode < 300) {
        state = Item();
        return true;
      }
    } catch (e) {
      print("Exception : $e");
      return false;
    }
    return false;
  }

  Future<bool> save(im.Item item) async {
    String url = '${const String.fromEnvironment('API_URL')}/api/v1/items';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };

    item.description ??= im.Description(
        userId: Supabase.instance.client.auth.currentUser!.id, data: "");
    item.description!.userId = Supabase.instance.client.auth.currentUser!.id;
    item.userId = Supabase.instance.client.auth.currentUser!.id;
    for (var sl in item.storageLocations ?? []) {
      sl.userId = Supabase.instance.client.auth.currentUser!.id;
      sl.storage?.userId = Supabase.instance.client.auth.currentUser!.id;
    }

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode([item]));
      if (response.statusCode < 300) {
        state = Item();
        return true;
      }
    } catch (e) {
      print("Exception : $e");
      return false;
    }
    return false;
  }
}
