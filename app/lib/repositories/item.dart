import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:librairian/models/item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemRepository {
  ItemRepository(this.client);
  final http.Client client;

  FutureOr<Item?> getItem(String id) async {
    String url = '${const String.fromEnvironment('API_URL')}/api/v1/item/$id';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        return Item.fromJson(data);
      } else {
        print("Http error : ${response.body}");
      }
    } catch (e) {
      print("Exception : $e");
      return null;
    }
    return null;
  }

  FutureOr<Item?> postItem(String id) {
    return null;
  }

  FutureOr<Item?> patchItem(Item item) {
    return null;
  }

  FutureOr<Item?> deleteItem(String id) {
    return null;
  }
}
