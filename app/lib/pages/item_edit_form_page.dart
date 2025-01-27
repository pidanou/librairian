import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:librairian/providers/item.dart";
import "package:librairian/widgets/item_edit_form.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemEditFormPage extends ConsumerStatefulWidget {
  final String itemId;

  const ItemEditFormPage({super.key, required this.itemId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      ItemEditFormPageState();
}

class ItemEditFormPageState extends ConsumerState<ItemEditFormPage> {
  @override
  Widget build(BuildContext context) {
    var item = ref.watch(itemControllerProvider(widget.itemId));
    if (item is AsyncData) {
      return Scaffold(
          appBar: AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surfaceDim,
              title: Text(
                  item.value?.name ?? AppLocalizations.of(context)!.noName),
              centerTitle: true),
          body: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceBright,
                  borderRadius: MediaQuery.of(context).size.width < 840
                      ? const BorderRadius.all(Radius.circular(0))
                      : const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0))),
              child: ItemEditForm(
                itemID: item.value!.id,
                onCancel: () => Navigator.of(context).pop(),
              )));
    }
    return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surfaceDim,
            centerTitle: true),
        body: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceBright,
                borderRadius: MediaQuery.of(context).size.width < 840
                    ? const BorderRadius.all(Radius.circular(0))
                    : const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0))),
            child: const Center(child: CircularProgressIndicator())));
  }
}
