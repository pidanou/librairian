import 'dart:math';

import 'package:flutter/material.dart';

class PageSwitcher extends StatelessWidget {
  const PageSwitcher(
      {super.key,
      required this.currentPage,
      required this.pageSize,
      required this.totalItem,
      required this.nextPage,
      required this.prevPage});

  final int currentPage;
  final int totalItem;
  final int pageSize;
  final VoidCallback nextPage;
  final VoidCallback prevPage;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage == 1
              ? null
              : () {
                  prevPage();
                }),
      const SizedBox(width: 10),
      Text(
          "${totalItem == 0 ? 0 : max((currentPage - 1) * pageSize, 1)} - ${min((currentPage - 1) * pageSize + pageSize, totalItem)} of $totalItem"),
      const SizedBox(width: 10),
      IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: (currentPage - 1) * pageSize + pageSize < totalItem
            ? () {
                nextPage();
              }
            : null,
      )
    ]);
  }
}
