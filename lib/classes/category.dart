import 'package:flutter/material.dart';

class Category {
  final String id;
  final String category;
  final String colorHex;

  Category({required this.id, required this.category, required this.colorHex});

  factory Category.fromMap(Map<String, dynamic> data, String documentId) {
    return Category(
      id: documentId,
      category: data['category'],
      colorHex: data['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'colorHex': colorHex,
    };
  }

  Color colorFromString() {
    try {
      final hexColor = colorHex.replaceAll('#', '');
      return Color(int.parse(hexColor, radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }
}
