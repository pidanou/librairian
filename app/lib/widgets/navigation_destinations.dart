import 'package:flutter/material.dart';
import 'package:librairian/constants/keys.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Destination {
  const Destination(this.icon, this.label, this.key);
  final IconData icon;
  final String label;
  final GlobalKey key;
}

List<Destination> getDestinations(BuildContext context) {
  return [
    Destination(
        Icons.search, AppLocalizations.of(context)!.search, searchNavKey),
    Destination(
        Icons.shelves, AppLocalizations.of(context)!.storage, storageNavKey),
    Destination(Icons.list_alt, AppLocalizations.of(context)!.inventory,
        inventoryNavKey),
    Destination(
        Icons.settings, AppLocalizations.of(context)!.settings, settingsNavKey)
  ];
}
