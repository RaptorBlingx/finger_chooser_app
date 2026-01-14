import 'package:flutter/material.dart';

class DarePack {
  final String id;
  final String name;
  final String description;
  final String price; // e.g., "Free", "$0.99"
  final IconData iconData;
  final bool isFree;
  final int dareCount;
  final String category; // 'mild', 'spicy', 'wild', 'all'

  DarePack({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.iconData,
    required this.isFree,
    required this.dareCount,
    required this.category,
  });
}
