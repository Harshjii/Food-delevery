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

  // New Fields for Sizes and Ingredients
  final Map<String, double> sizePrices; // e.g., {'Small': 8.99, 'Medium': 10.99, 'Large': 12.99}
  final List<Map<String, dynamic>> ingredients; // e.g., [{'name': 'Chicken (250 gm)', 'price': 1.40}]

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

  // Convert object to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
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

  // Factory constructor to create FoodItem from Firestore Document
  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
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
      sizePrices: Map<String, double>.from(
        data['sizePrices'] ?? {'Small': 8.99, 'Medium': 10.99, 'Large': 12.99},
      ),
      ingredients: List<Map<String, dynamic>>.from(
        data['ingredients'] ?? [
          {'name': 'Chicken (250 gm)', 'price': 1.40},
          {'name': 'Mashroom (50 gm)', 'price': 0.40}
        ],
      ),
    );
  }
}