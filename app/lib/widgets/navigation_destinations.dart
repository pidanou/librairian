import 'package:flutter/material.dart';
import 'package:librairian/constants/keys.dart';

class Destination {
  const Destination(this.icon, this.label, this.key);
  final IconData icon;
  final String label;
  final GlobalKey key;
}

List<Destination> navigationDestinations = <Destination>[
  Destination(Icons.search, 'Search', searchNavKey),
  Destination(Icons.shelves, 'Storage', storageNavKey),
  Destination(Icons.list_alt, 'Inventory', inventoryNavKey),
  Destination(Icons.settings, 'Settings', settingsNavKey),
];
