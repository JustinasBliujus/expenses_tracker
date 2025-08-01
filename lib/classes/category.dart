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
    try {
      final hexColor = color.replaceAll('#', '');
      return Color(int.parse(hexColor, radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }
}
