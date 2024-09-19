import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:librairian/models/attachment.dart';
import 'package:librairian/repositories/attachment.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'attachment.g.dart';

@riverpod
AttachmentRepository attachmentRepository(AttachmentRepositoryRef ref) {
  return AttachmentRepository(http.Client(), Supabase.instance.client);
}

@riverpod
Future<Uint8List> attachment(AttachmentRef ref, String fileName) async {
  return ref.watch(attachmentRepositoryProvider).getAttachment(fileName);
}

@riverpod
class ItemAttachmentsController extends _$ItemAttachmentsController {
  @override
  FutureOr<List<Attachment>> build(String? itemId) async {
    if (itemId == null) {
      return [];
    }
    return ref.watch(attachmentRepositoryProvider).listItemAttachments(itemId);
  }

  Future<void> postAttachment(
      String itemId, String fileName, Uint8List? bytes) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      List<Attachment> attachments = await ref
          .read(attachmentRepositoryProvider)
          .postAttachment(itemId, fileName, bytes);
      return [...state.value!, ...attachments];
    });
    return;
  }

  Future<void> deleteAttachment(Attachment attachment) async {
    state = await AsyncValue.guard(() async {
      await Supabase.instance.client.storage
          .from("attachments")
          .remove([attachment.path ?? ""]);
      await ref
          .read(attachmentRepositoryProvider)
          .deleteAttachmentEntry(attachment.id ?? "");
      return [...state.value!.where((element) => element.id != attachment.id)];
    });
  }
}
