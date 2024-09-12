import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:librairian/models/item.dart';
import 'package:librairian/providers/item.dart' as ip;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

part 'items_in_storage.g.dart';

@riverpod
class ItemsInStorage extends _$ItemsInStorage {
  @override
  Future<PaginatedItemsList?> build(int page, int limit,
      [String? storageID, String? orderBy = "name", bool? asc = false]) async {
    String url;
    if (storageID != null) {
      url =
          '${const String.fromEnvironment('API_URL')}/api/v1/items?limit=$limit&page=$page&storage_id=$storageID&order_by=$orderBy&asc=$asc';
    } else {
      url =
          '${const String.fromEnvironment('API_URL')}/api/v1/items?limit=$limit&page=$page&order_by=$orderBy&asc=$asc';
    }
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {"Authorization": "Bearer $token"};

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        return PaginatedItemsList.fromJson(data);
      } else {
        print("Http error : ${response.body}");
      }
    } catch (e) {
      print("Exception : $e");
      return null;
    }
    return null;
  }

  Future<void> delete(String itemID) async {
    String url =
        '${const String.fromEnvironment('API_URL')}/api/v1/item/$itemID';
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
        print("Http error : ${response.body}");
      }
    } catch (e) {
      print("Exception : $e");
      return;
    }
    return;
  }

  Future<Item?> save(Item item) async {
    item.userId = Supabase.instance.client.auth.currentUser!.id;
    for (var sl in item.locations ?? []) {
      sl.userId = Supabase.instance.client.auth.currentUser!.id;
      sl.storage?.userId = Supabase.instance.client.auth.currentUser!.id;
    }

    Item? newItem;
    if (item.id == null) {
      newItem = await ref.read(ip.itemProvider(item.id).notifier).add(item);
    } else {
      newItem = await ref.read(ip.itemProvider(item.id).notifier).patch(item);
    }

    int index = state.value!.data.indexWhere((e) => e.id == item.id);
    var tmp = state;
    if (index == -1) {
      tmp.value!.data.insert(0, newItem ?? Item());
    } else {
      tmp.value!.data[index] = newItem ?? Item();
    }
    tmp.value!.metadata.total = tmp.value!.data.length;
    state = tmp;
    return newItem;
  }
}
