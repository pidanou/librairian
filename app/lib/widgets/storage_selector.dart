import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/providers/storage.dart' as storage_provider;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StorageSelector extends ConsumerStatefulWidget {
  final void Function(Storage?)? onSelected;
  final EdgeInsets? expandedInsets;
  final Storage? initialSelection;

  const StorageSelector({
    super.key,
    this.onSelected,
    this.expandedInsets,
    this.initialSelection,
  });

  @override
  ConsumerState<StorageSelector> createState() => _StorageSelectorState();
}

class _StorageSelectorState extends ConsumerState<StorageSelector> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final storages = ref.watch(storage_provider.storagesProvider);
    if (storages is AsyncError) {
      return Text(AppLocalizations.of(context)!.error);
    }

    if (storages is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final storageList = storages.value ?? [];

    return Row(children: [
      Expanded(
          child: DropdownMenu<Storage>(
        inputDecorationTheme: Theme.of(context).inputDecorationTheme,
        controller: controller,
        initialSelection: widget.initialSelection,
        label: Text(AppLocalizations.of(context)!.storage),
        onSelected: widget.onSelected,
        expandedInsets: widget.expandedInsets,
        dropdownMenuEntries: storageList.map<DropdownMenuEntry<Storage>>(
          (Storage storage) {
            return DropdownMenuEntry<Storage>(
              value: storage,
              label: storage.alias,
            );
          },
        ).toList(),
      )),
    ]);
  }
}
