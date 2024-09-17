import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:librairian/models/attachment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttachmentRepository {
  AttachmentRepository(this.httpClient, this.supabaseClient);
  final http.Client httpClient;
  final SupabaseClient supabaseClient;

  FutureOr<List<Attachment>> listItemAttachments(String itemId) async {
    String url =
        '${const String.fromEnvironment('API_URL')}/api/v1/item/$itemId/attachments';
    final token = supabaseClient.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        return (data as List).map((item) => Attachment.fromJson(item)).toList();
      } else {
        print("Http error : ${response.body}");
      }
    } catch (e) {
      print("Exception : $e");
      return [];
    }
    return [];
  }

  FutureOr<Uint8List> getAttachment(String path) async {
    return await supabaseClient.storage.from("attachments").download(path);
  }

  Future<String?> uploadAttachment(String? itemId, String fileName,
      {File? file, Uint8List? bytes}) async {
    String userId = supabaseClient.auth.currentUser!.id;
    fileName = fileName.split("/").last;
    String itemName = "$userId/$itemId/$fileName";
    if (file != null) {
      return await supabaseClient.storage.from("attachments").upload(
            itemName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
    }
    if (bytes != null) {
      return await supabaseClient.storage.from("attachments").uploadBinary(
            itemName,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
    }
    return null;
  }

  Future<List<Attachment>> postAttachment(String? itemId, String fileName,
      {File? file, Uint8List? bytes}) async {
    String? objectId;
    try {
      objectId =
          await uploadAttachment(itemId, fileName, file: file, bytes: bytes);
    } catch (e) {
      print("Cannot upload attachment : $e");
      return [];
    }

    if (objectId == null) {
      return [];
    }

    fileName = fileName.split("/").last;
    String path = "${supabaseClient.auth.currentUser!.id}/$itemId/$fileName";

    Attachment attachment = Attachment(
      userId: supabaseClient.auth.currentUser!.id,
      itemId: itemId,
      path: path,
    );

    String url =
        '${const String.fromEnvironment('API_URL')}/api/v1/attachments';
    final token = supabaseClient.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };
    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode([attachment.toJson()]));
      if (response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) => Attachment.fromJson(item)).toList();
        } else {
          print("Data is not a list");
          return [];
        }
      } else {
        print("Http error : ${response.body}");
      }
    } catch (e) {
      print("Exception : $e");
      return [];
    }
    return [];
  }

  Future<void> deleteAttachmentEntry(String id) async {
    String url =
        '${const String.fromEnvironment('API_URL')}/api/v1/attachment/$id';
    final token = supabaseClient.auth.currentSession?.accessToken;
    final headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json"
    };
    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode < 300) {
        return;
      } else {
        print("Http error : ${response.body}");
      }
    } catch (e) {
      print("Exception : $e");
    }
  }
}
