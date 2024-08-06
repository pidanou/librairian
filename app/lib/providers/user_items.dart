import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:librairian/models/item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

part 'user_items.g.dart';

@riverpod
class UserItems extends _$UserItems {
  @override
  Future<PaginatedItemsList?> build(int page, int limit,
      [String? storageID, String? orderBy = "name", bool? asc = false]) async {
    String url;
    if (storageID != null) {
      url =
          'http://localhost:8080/api/v1/items?limit=$limit&page=$page&storage_id=$storageID&order_by=$orderBy&asc=$asc';
    } else {
      url =
          'http://localhost:8080/api/v1/items?limit=$limit&page=$page&order_by=$orderBy&asc=$asc';
    }
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {"Authorization": "Bearer $token"};

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        return PaginatedItemsList.fromJson(data);
      } else {
        print("Erreur HTTP getting all items : ${response.statusCode}");
      }
    } catch (e) {
      print("Exception : $e");
      return null;
    }
    return null;
  }

  void add(List<Item> items) {
    if (state.value != null) {
      var tmp = state.value;
      tmp!.data.insertAll(0, items);
      state = AsyncValue.data(tmp); // Assuming AsyncValue or similar wrapper
    }
  }

  void remove(String id) {
    if (state.value != null) {
      var tmp = state.value;
      tmp!.data.removeWhere((i) => i.tmpId == id || i.id == id);
      state = AsyncValue.data(tmp); // Assuming AsyncValue or similar wrapper
    }
  }

  Future<void> delete(String itemID) async {
    String url = 'http://localhost:8080/api/v1/item/$itemID';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
    };
    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode < 300) {
        var tmp = state;
        tmp.value?.data.removeWhere((e) => e.id == itemID);
        state = tmp;
        return;
      } else {
        print("Erreur HTTP getting all items : ${response.statusCode}");
      }
    } catch (e) {
      print("Exception : $e");
      return;
    }
    return;
  }

  Future<void> save(Item item) async {
    String url = 'http://localhost:8080/api/v1/item/';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };

    item.description ??= Description(
        userId: Supabase.instance.client.auth.currentUser!.id, data: "");
    item.description!.userId = Supabase.instance.client.auth.currentUser!.id;
    item.userId = Supabase.instance.client.auth.currentUser!.id;
    for (var sl in item.storageLocations ?? []) {
      sl.userId = Supabase.instance.client.auth.currentUser!.id;
      sl.storage?.userId = Supabase.instance.client.auth.currentUser!.id;
    }
    if (item.id == null) {
      url = 'http://localhost:8080/api/v1/items';
      try {
        final response = await http.post(Uri.parse(url),
            headers: headers, body: jsonEncode([item]));
        if (response.statusCode < 300) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final newItem = Item.fromJson(data["successes"][0]);
          final tmp = state.value;
          tmp?.data.insert(0, newItem);
          tmp?.data.removeWhere((i) => i.tmpId == item.tmpId);
          state = AsyncValue.data(tmp);

          return;
        }
      } catch (e) {
        print("Exception : $e");
        return;
      }
      return;
    }

    url = 'http://localhost:8080/api/v1/item';
    try {
      final response = await http.put(Uri.parse(url),
          headers: headers, body: jsonEncode(item));
      if (response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        int index = state.value!.data.indexWhere((e) => e.id == item.id);
        var tmp = state;
        tmp.value!.data[index] = Item.fromJson(data);
        state = tmp;
      }
    } catch (e) {
      print("Exception : $e");
      return;
    }
    return;
  }
}