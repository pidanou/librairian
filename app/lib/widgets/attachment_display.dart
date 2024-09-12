import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/attachment.dart';
import 'package:librairian/widgets/image_viewer.dart';

class AttachmentDisplay extends ConsumerWidget {
  final List<String> attachments;
  final Function(String) onRemove;

  const AttachmentDisplay({
    super.key,
    required this.attachments,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
        height: 200,
        width: double.infinity,
        child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 20),
            scrollDirection: Axis.horizontal,
            itemCount: attachments.length,
            itemBuilder: (context, index) {
              var attachment =
                  ref.watch(attachmentProvider(attachments[index]));

              if (attachment is AsyncData) {
                return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: ImageViewer(
                      image: Image.memory(attachment.value!),
                      onDelete: () {
                        onRemove(attachments[index]);
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
                    onRemove(attachments[index]);
                  },
                );
              }
              return const SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator())));
            }));
  }
}
