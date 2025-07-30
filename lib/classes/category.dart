import 'package:flutter/material.dart';

class Category {
  final String id;
  final String category;
  final String color;

  Category({
    required this.id,
    required this.category,
    required this.color,
  });

  // Factory constructor to create a Category object from Firestore document data
  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      category: map['category'] ?? 'Unknown',
      color: map['color'] ?? 'Unknown',
    );
  }

  // Method to convert Category to a map
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'color': color,
    };
  }

  // Instance method to convert the color string to a Color object
  Color colorFromString() {
    // Handle named colors
    final namedColors = {
      'Red': Colors.red,
      'Green': Colors.green,
      'Blue': Colors.blue,
      'Yellow': Colors.yellow,
      'Orange': Colors.orange,
      'Purple': Colors.purple,
      'Cyan': Colors.cyan,
      'Brown': Colors.brown,
      'Black': Colors.black,
      'Pink': Colors.pink,
      'Indigo': Colors.indigo,
    };

    if (namedColors.containsKey(color)) {
      return namedColors[color]!;
    }

    // Handle hexadecimal colors
    try {
      final hexColor = color.replaceAll('#', '');
      return Color(int.parse(hexColor, radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }
}
