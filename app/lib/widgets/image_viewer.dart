import "package:flutter/material.dart";

class ImageViewer extends StatelessWidget {
  final Widget image;
  final VoidCallback? onDelete;

  const ImageViewer({super.key, required this.image, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topRight, children: [
      GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: image,
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
