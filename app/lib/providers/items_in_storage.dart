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
    try {
      ref.read(ip.itemControllerProvider(itemID).notifier).delete(itemID);
    } catch (e) {
      print(e);
      return;
    }
    var tmp = state;
    tmp.value?.data.removeWhere((e) => e.id == itemID);
    state = tmp;
    return;
  }

  Future<Item?> save(Item item) async {
    item.userId = Supabase.instance.client.auth.currentUser!.id;
    for (var sl in item.locations ?? []) {
      sl.userId = Supabase.instance.client.auth.currentUser!.id;
      sl.storage?.userId = Supabase.instance.client.auth.currentUser!.id;
    }

    Item? newItem;
    if (item.id == "") {
      newItem =
          await ref.read(ip.itemControllerProvider(item.id).notifier).add(item);
    } else {
      newItem = await ref
          .read(ip.itemControllerProvider(item.id).notifier)
          .patch(item);
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      int index = state.value!.data.indexWhere((e) => e.id == item.id);
      var tmp = state.value!;
      if (index == -1) {
        tmp.data.insert(0, newItem ?? Item());
      } else {
        tmp.data[index] = newItem ?? Item();
      }
      tmp.metadata.total = tmp.data.length;
      return tmp;
    });

    return newItem;
  }
}
