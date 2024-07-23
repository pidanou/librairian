import 'package:flutter/material.dart';

class ManageMenu extends StatelessWidget {
  final void Function(String)? onTap;
  final String selectedMenu;

  const ManageMenu({super.key, this.onTap, this.selectedMenu = "storages"});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      IconButton(
          isSelected: selectedMenu == "storages",
          icon: const Icon(Icons.inventory_2),
          onPressed: () {
            onTap?.call('storages');
          },
          tooltip: 'Storages'),
      IconButton(
          isSelected: selectedMenu == "items",
          tooltip: 'Items',
          icon: const Icon(Icons.category),
          onPressed: () {
            onTap?.call('items');
          }),
      IconButton(
          isSelected: selectedMenu == "tags",
          tooltip: 'Tags',
          icon: const Icon(Icons.tag),
          onPressed: () {
            onTap?.call('tags');
          }),
      IconButton(
          isSelected: selectedMenu == "usage",
          tooltip: 'Usage',
          icon: const Icon(Icons.data_usage),
          onPressed: () {
            onTap?.call('usage');
          })
    ]);
  }
}
