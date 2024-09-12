import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:librairian/models/item.dart' as im;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:http/http.dart' as http;

part 'item.g.dart';

@riverpod
class Item extends _$Item {
  @override
  Future<im.Item> build(String? id) async {
    if (id == null) {
      return im.Item();
    }
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
        return im.Item.fromJson(data);
      } else {
        print("Http error : ${response.body}");
      }
    } catch (e) {
      print("Exception : $e");
      return im.Item();
    }
    return im.Item();
  }

  void set(im.Item item) {
    state = AsyncValue.data(item);
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
        state = AsyncValue.data(im.Item());
        return true;
      }
    } catch (e) {
      print("Exception : $e");
      return false;
    }
    return false;
  }

  Future<im.Item?> patch(im.Item item) async {
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
        im.Item newItem = im.Item.fromJson(jsonDecode(response.body));
        state = AsyncValue.data(newItem);
        return newItem;
      }
    } catch (e) {
      print("Exception : $e");
      return null;
    }
    return null;
  }

  Future<im.Item?> add(im.Item item) async {
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
        im.Item newItem = im.Item.fromJson(jsonDecode(response.body));
        state = AsyncValue.data(newItem);
        return newItem;
      }
    } catch (e) {
      print("Exception : $e");
      return null;
    }

    return null;
  }

  Future<void> addAttachment(String? itemId, String fileName,
      {File? file, Uint8List? bytes}) async {
    String userId = Supabase.instance.client.auth.currentUser!.id;
    fileName = fileName.split("/").last;
    String itemName = "$userId/$itemId/$fileName";
    if (file != null) {
      await Supabase.instance.client.storage.from("attachments").upload(
            itemName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
    }
    if (bytes != null) {
      await Supabase.instance.client.storage.from("attachments").uploadBinary(
            itemName,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
    }

    im.Item oldItem = state.value ?? im.Item();
    if (itemId == null) {
      oldItem.attachments = [itemName, ...oldItem.attachments ?? []];
      if (await add(oldItem) == null) {
        await Supabase.instance.client.storage
            .from("attachments")
            .remove([itemName]);
      }
    } else {
      oldItem.attachments = [itemName, ...oldItem.attachments ?? []];
      if (await patch(oldItem) == null) {
        await Supabase.instance.client.storage
            .from("attachments")
            .remove([itemName]);
      }
      state = AsyncValue.data(oldItem);
    }

    return;
  }

  Future<void> removeAttachment(String? itemId, String fileName) async {
    await Supabase.instance.client.storage
        .from("attachments")
        .remove([fileName]);
    im.Item oldItem = state.value ?? im.Item();
    oldItem.attachments =
        oldItem.attachments?.where((element) => element != fileName).toList();
    await patch(oldItem);
    state = AsyncValue.data(oldItem);
  }
}
