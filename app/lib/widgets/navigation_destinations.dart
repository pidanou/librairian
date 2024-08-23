import 'package:flutter/material.dart';

class Destination {
  const Destination(this.icon, this.label);
  final IconData icon;
  final String label;
}

const List<Destination> navigationDestinations = <Destination>[
  Destination(Icons.search, 'Search'),
  Destination(Icons.library_add, 'Add'),
  Destination(Icons.shelves, 'Storage'),
  Destination(Icons.list_alt, 'Inventory'),
  Destination(Icons.settings, 'Settings'),
];
