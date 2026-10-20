import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String id;
  final String name;
  final String restaurant;
  final double price;
  final double rating;
  final int reviewsCount;
  final int calories;
  final int deliveryTimeMin;
  final String imageUrl;
  final String category;

  // Size Prices ko double? banaya gaya hai taaki unhe nullable (Not Available) rakha ja sake
  final Map<String, double?> sizePrices;
  final List<Map<String, dynamic>> ingredients;

  FoodItem({
    required this.id,
    required this.name,
    required this.restaurant,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.calories,
    required this.deliveryTimeMin,
    required this.imageUrl,
    required this.category,
    required this.sizePrices,
    required this.ingredients,
  });

  // Convert object to JSON / Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'restaurant': restaurant,
      'price': price,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'calories': calories,
      'deliveryTimeMin': deliveryTimeMin,
      'imageUrl': imageUrl,
      'category': category,
      'sizePrices': sizePrices,
      'ingredients': ingredients,
    };
  }

  // Alias for compatibility if needed elsewhere
  Map<String, dynamic> toJson() => toMap();

  // Factory constructor to create FoodItem from Firestore Document
  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    // Safely parse sizePrices with nullable support
    Map<String, double?> parsedSizes = {'Small': null, 'Medium': 250.0, 'Large': null};
    if (data['sizePrices'] != null) {
      data['sizePrices'].forEach((key, value) {
        if (value != null) {
          parsedSizes[key.toString()] = (value as num).toDouble();
        } else {
          parsedSizes[key.toString()] = null;
        }
      });
    }

    return FoodItem(
      id: doc.id,
      name: data['name'] ?? '',
      restaurant: data['restaurant'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
      calories: data['calories'] ?? 0,
      deliveryTimeMin: data['deliveryTimeMin'] ?? 20,
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      sizePrices: parsedSizes,
      ingredients: List<Map<String, dynamic>>.from(
        data['ingredients'] ?? [
          {'name': 'Chicken (250 gm)', 'price': 1.40},
          {'name': 'Mashroom (50 gm)', 'price': 0.40}
        ],
      ),
    );
  }

  // Factory constructor to create FoodItem from a Map (used in Providers)
  factory FoodItem.fromMap(Map<String, dynamic> map, String documentId) {
    Map<String, double?> parsedSizes = {};
    if (map['sizePrices'] != null) {
      (map['sizePrices'] as Map).forEach((key, value) {
        parsedSizes[key.toString()] = value != null ? (value as num).toDouble() : null;
      });
    }

    return FoodItem(
      id: documentId,
      name: map['name'] ?? '',
      restaurant: map['restaurant'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: map['reviewsCount'] ?? 0,
      calories: map['calories'] ?? 0,
      deliveryTimeMin: map['deliveryTimeMin'] ?? 20,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      sizePrices: parsedSizes,
      ingredients: map['ingredients'] != null
          ? List<Map<String, dynamic>>.from(map['ingredients'])
          : [],
    );
  }
}