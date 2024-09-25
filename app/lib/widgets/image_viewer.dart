import "package:flutter/material.dart";

class ImageViewer extends StatelessWidget {
  final Widget image;
  final VoidCallback? onDelete;
  final Widget? caption;

  const ImageViewer(
      {super.key, required this.image, this.onDelete, this.caption});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topRight, children: [
      GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: caption,
                    content: image,
                  );
                });
          },
          child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              height: 200,
              width: 200,
              child: image)),
      IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            onDelete?.call();
          }),
    ]);
  }
}
