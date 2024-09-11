import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentsPicker extends StatefulWidget {
  const AttachmentsPicker({super.key, required this.onAdd});
  final Function(List<XFile>) onAdd;

  @override
  State<AttachmentsPicker> createState() => AttachmentsPickerState();
}

class AttachmentsPickerState extends State<AttachmentsPicker> {
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (!kIsWeb) ...[
        FilledButton.tonalIcon(
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Camera'),
            onPressed: () async {
              final XFile? image =
                  await picker.pickImage(source: ImageSource.camera);
              if (image != null) {
                widget.onAdd([image]);
              }
            }),
        const SizedBox(width: 10)
      ],
      FilledButton.tonalIcon(
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Gallery'),
          onPressed: () async {
            final List<XFile> images = await picker.pickMultiImage();
            widget.onAdd(images);
          }),
    ]);
  }
}
