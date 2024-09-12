import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'attachment.g.dart';

@riverpod
Future<Uint8List> attachment(AttachmentRef ref, String fileName) async {
  return await Supabase.instance.client.storage
      .from("attachments")
      .download(fileName);
}
