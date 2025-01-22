import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/attachment.dart';
import 'package:librairian/widgets/default_error.dart';
import 'package:librairian/widgets/image_viewer.dart';

class AttachmentDisplay extends ConsumerWidget {
  final String itemId;

  const AttachmentDisplay({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var attachments = ref.watch(itemAttachmentsControllerProvider(itemId));
    if (attachments is AsyncError) {
      return const DefaultError();
    }
    if (attachments is AsyncData && attachments.value!.isNotEmpty) {
      return ListTile(
          title: SizedBox(
              height: 200,
              child: ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: attachments.value?.length ?? 0,
                  itemBuilder: (context, index) {
                    var attachment = ref.watch(attachmentProvider(
                        attachments.value![index].path ?? ""));
                    if (attachment is AsyncData || attachment is AsyncError) {
                      return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: ImageViewer(
                            // caption: Text(
                            //     attachments.value![index].captions ?? "",
                            //     style: Theme.of(context).textTheme.bodySmall),
                            image: (attachment is AsyncData)
                                ? Image.memory(attachment.value!)
                                : const SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: Center(
                                        child: Icon(Icons.error, size: 50))),
                            onDelete: () {
                              ref
                                  .read(
                                      itemAttachmentsControllerProvider(itemId)
                                          .notifier)
                                  .deleteAttachment(attachments.value![index]);
                            },
                          ));
                    }
                    return const SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                            child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator())));
                  })));
    }
    return const SizedBox();
  }
}
