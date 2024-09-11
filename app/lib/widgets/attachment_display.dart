import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/attachment.dart';
import 'package:librairian/widgets/image_viewer.dart';

class AttachmentDisplay extends ConsumerWidget {
  final List<String> attachments;
  final List<String> newAttachments;
  final Function(List<String>) onRemove;
  final Function(List<String>) onRemoveNew;

  const AttachmentDisplay(
      {super.key,
      required this.attachments,
      required this.onRemove,
      required this.onRemoveNew,
      required this.newAttachments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
        height: 200,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (var i = 0; i < newAttachments.length; i++) ...[
            ImageViewer(
              image: Image.file(File(newAttachments[i])),
              onDelete: () {
                List<String> updated = newAttachments;
                updated.removeAt(i);
                onRemoveNew(updated);
              },
            ),
            const SizedBox(width: 20),
          ],
          ...List.generate(attachments.length, (index) {
            var attachment = ref.watch(attachmentProvider(attachments[index]));

            if (attachment is AsyncData) {
              return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: ImageViewer(
                    image: Image.memory(attachment.value!),
                    onDelete: () {
                      List<String> newAttachments = attachments;
                      newAttachments.removeAt(index);
                      onRemove(newAttachments);
                    },
                  ));
            }
            if (attachment is AsyncError) {
              return ImageViewer(
                image: const SizedBox(
                    height: 200,
                    width: 200,
                    child: Center(child: Icon(Icons.error, size: 50))),
                onDelete: () {
                  List<String> updated = attachments;
                  updated.removeAt(index);
                  onRemove([...newAttachments, ...updated]);
                },
              );
            }
            return const SizedBox(
                width: 50,
                height: 50,
                child: Center(child: CircularProgressIndicator()));
          })
        ]));
  }
}
