import 'package:flutter/material.dart'; // For IconData

class DarePack {
  final String id;
  final String name;
  final String description;
  final String price; // e.g., "Free", "$0.99"
  final IconData iconData; // Using IconData for placeholder icon

  DarePack({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.iconData,
  });
}
