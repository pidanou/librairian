import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/storage.dart' as storage_provider;
import 'package:librairian/providers/storage.dart';
import 'package:librairian/widgets/dialog_add_storage.dart';

class DefaultStorageSelector extends ConsumerStatefulWidget {
  final EdgeInsets? expandedInsets;

  const DefaultStorageSelector({
    super.key,
    this.expandedInsets,
  });

  @override
  ConsumerState<DefaultStorageSelector> createState() => _DeviceSelectorState();
}

class _DeviceSelectorState extends ConsumerState<DefaultStorageSelector> {
  MenuController controller = MenuController();

  @override
  Widget build(BuildContext context) {
    var storages = ref.watch(storage_provider.storagesProvider);
    final defaultStorage = ref.watch(defaultStorageProvider);

    if (defaultStorage is AsyncError || storages is AsyncError) {
      return const Text("Error");
    }
    if (defaultStorage is AsyncLoading || storages is AsyncLoading) {
      return AnimatedSwitcher(
          duration: const Duration(milliseconds: 1000),
          child: FilledButton(
              child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      backgroundColor:
                          Theme.of(context).colorScheme.onPrimary)),
              onPressed: () {}));
    }

    return MenuAnchor(
        controller: controller,
        builder: (context, controller, child) {
          return FilledButton.icon(
            label: Text(defaultStorage != null
                ? defaultStorage.alias ?? ""
                : "No default storage"),
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
          );
        },
        menuChildren: [
          for (var storage in storages.value ?? [])
            ListTile(
                title: Text(storage.alias ?? ""),
                onTap: () {
                  controller.close();
                  ref.read(defaultStorageProvider.notifier).set(storage);
                }),
          ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text("No default storage"),
              onTap: () {
                controller.close();
                ref.read(defaultStorageProvider.notifier).set(null);
              }),
          ListTile(
              title: const Text("New storage"),
              leading: const Icon(Icons.add_circle),
              onTap: () {
                controller.close();
                showDialog(
                    context: context,
                    builder: (context) {
                      return const DialogAddStorage();
                    });
              })
        ]);
  }
}
