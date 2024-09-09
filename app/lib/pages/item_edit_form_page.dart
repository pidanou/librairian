import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:librairian/models/item.dart";
import "package:librairian/providers/item.dart" as provider;
import "package:librairian/widgets/item_edit_form.dart";

class ItemEditFormPage extends ConsumerStatefulWidget {
  final Item? item;
  final String itemId;

  const ItemEditFormPage({super.key, this.item, required this.itemId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      ItemEditFormPageState();
}

class ItemEditFormPageState extends ConsumerState<ItemEditFormPage> {
  late Item item;

  @override
  void initState() {
    super.initState();
    if (widget.item == null) {
      ref
          .read(provider.itemProvider.notifier)
          .getById(widget.itemId)
          .then((value) {
        item = value;
      });
      return;
    }
    item = widget.item ?? Item();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surfaceDim,
            title: Text(item.name ?? 'No name'),
            centerTitle: true),
        body: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceBright,
                borderRadius: MediaQuery.of(context).size.width < 600
                    ? const BorderRadius.all(Radius.circular(0))
                    : const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0))),
            child: ItemEditForm(
                item: item,
                onCancel: () => Navigator.of(context).pop(),
                onSave: (item) {
                  Navigator.of(context).pop();
                })));
  }
}
