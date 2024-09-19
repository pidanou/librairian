import 'dart:convert';

import 'package:librairian/models/item.dart';
import 'package:librairian/repositories/item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:http/http.dart' as http;

part 'item.g.dart';

@riverpod
ItemRepository itemRepository(ItemRepositoryRef ref) {
  return ItemRepository(http.Client());
}

@riverpod
class ItemController extends _$ItemController {
  @override
  Future<Item?> build(String? id) async {
    if (id == null) {
      return null;
    }
    Item? newItem = await ref.watch(itemRepositoryProvider).getItem(id);
    return newItem;
  }

  Future<bool> delete(String id) async {
    String url = '${const String.fromEnvironment('API_URL')}/api/v1/item/$id';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };
    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode < 300) {
        state = AsyncValue.data(Item());
        return true;
      }
    } catch (e) {
      print("Exception : $e");
      return false;
    }
    return false;
  }

  Future<Item?> patch(Item item) async {
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
        state = AsyncValue.data(newItem);
        return newItem;
      }
    } catch (e) {
      print("Exception : $e");
      return null;
    }
    return null;
  }

  Future<Item?> add(Item item) async {
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
        state = AsyncValue.data(newItem);
        return newItem;
      }
    } catch (e) {
      print("Exception : $e");
      return null;
    }

    return null;
  }

  Future<Item?> save(Item item) async {
    if (item.id == null) {
      return add(item);
    } else {
      return patch(item);
    }
  }
}
