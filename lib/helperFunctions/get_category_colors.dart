import 'dart:ui';
import '../classes/category.dart';

Map<String, Color> getCategoryColors(List<Category> categories) {
  return {
    for (var cat in categories)
      cat.category: cat.colorFromString(),
  };
}
