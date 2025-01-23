import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:librairian/models/item.dart';
import 'package:librairian/models/storage.dart';
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

  Future<Item?> postItem(Item item) async {
    String url = '${const String.fromEnvironment('API_URL')}/api/v1/item';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };

    item.userId = Supabase.instance.client.auth.currentUser!.id;
    for (var sl in item.locations ?? []) {
      sl.userId = Supabase.instance.client.auth.currentUser!.id;
      sl.storage?.userId = Supabase.instance.client.auth.currentUser!.id;
    }

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(item));
      if (response.statusCode < 300) {
        Item newItem = Item.fromJson(jsonDecode(response.body));
        return newItem;
      }
    } catch (e) {
      print("Exception : $e");
      return null;
    }
    return null;
  }

  FutureOr<Item?> patchItem(Item item) async {
    String url =
        '${const String.fromEnvironment('API_URL')}/api/v1/item/${item.id}';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };

    item.userId = Supabase.instance.client.auth.currentUser!.id;
    for (var sl in item.locations ?? []) {
      sl.userId = Supabase.instance.client.auth.currentUser!.id;
      sl.storage?.userId = Supabase.instance.client.auth.currentUser!.id;
    }

    try {
      final response = await http.patch(Uri.parse(url),
          headers: headers, body: jsonEncode(item));
      if (response.statusCode < 300) {
        Item newItem = Item.fromJson(jsonDecode(response.body));
        return getItem(newItem.id);
      }
    } catch (e) {
      print("Exception : $e");
      return null;
    }
    return null;
  }

  FutureOr<void> deleteItem(String id) async {
    String url = '${const String.fromEnvironment('API_URL')}/api/v1/item/$id';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };
    try {
      await http.delete(Uri.parse(url), headers: headers);
    } catch (e) {
      print("Exception : $e");
      rethrow;
    }
  }

  FutureOr<Item?> addLocation(Location location) async {
    String url =
        '${const String.fromEnvironment('API_URL')}/api/v1/item/${location.itemId}/location';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };

    location.userId = Supabase.instance.client.auth.currentUser!.id;

    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(location));
      if (response.statusCode < 300) {
        Item newItem = Item.fromJson(jsonDecode(response.body));
        return newItem;
      }
    } catch (e) {
      print("Exception : $e");
      return null;
    }
    return null;
  }

  FutureOr<void> deleteLocation(String id) async {
    String url =
        '${const String.fromEnvironment('API_URL')}/api/v1/location/$id';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };

    try {
      await http.delete(Uri.parse(url), headers: headers);
      return;
    } catch (e) {
      print("Exception : $e");
      rethrow;
    }
  }
}
