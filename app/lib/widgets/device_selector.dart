import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/device.dart';
import 'package:librairian/providers/storage.dart' as storage_provider;

class DeviceSelector extends ConsumerStatefulWidget {
  final EdgeInsets? expandedInsets;

  const DeviceSelector({
    super.key,
    this.expandedInsets,
  });

  @override
  ConsumerState<DeviceSelector> createState() => _DeviceSelectorState();
}

class _DeviceSelectorState extends ConsumerState<DeviceSelector> {
  MenuController controller = MenuController();

  @override
  Widget build(BuildContext context) {
    var devices = ref.watch(storage_provider.deviceProvider);
    final currentDevice = ref.watch(currentDeviceProvider);

    if (currentDevice is AsyncError) return const Text("Error");
    if (currentDevice is AsyncLoading) {
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
            icon: const Icon(Icons.devices),
            label: Text(currentDevice != null
                ? currentDevice.alias ?? ""
                : "Select a device"),
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
          for (var dev in devices)
            ListTile(
                title: Text(dev.alias ?? ""),
                onTap: () {
                  controller.close();
                  ref.read(currentDeviceProvider.notifier).set(dev);
                }),
          ListTile(
              title: const Text("New device"),
              leading: const Icon(Icons.add),
              onTap: () {
                controller.close();
              })
        ]);
  }
}
