import 'package:flutter/foundation.dart';
import '../models/food_item.dart';

class MenuProvider with ChangeNotifier {
  // Store WhatsApp number jo Admin update kar sake
  String _adminWhatsAppNumber = "919027723883";

  String get adminWhatsAppNumber => _adminWhatsAppNumber;

  void updateWhatsAppNumber(String newNumber) {
    _adminWhatsAppNumber = newNumber.replaceAll('+', '').replaceAll(' ', '');
    notifyListeners();
  }

  // Active Menu List
  final List<FoodItem> _foods = [
    FoodItem(
      id: '1',
      name: 'Melting Cheese Pizza',
      restaurant: 'Pizza Italiano',
      price: 10.99,
      rating: 4.8,
      reviewsCount: 2200,
      calories: 44,
      deliveryTimeMin: 20,
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500',
      category: 'Fast Food',
    ),
    FoodItem(
      id: '2',
      name: 'Cheese Burger',
      restaurant: 'Burger Hunt',
      price: 4.99,
      rating: 4.7,
      reviewsCount: 1500,
      calories: 44,
      deliveryTimeMin: 20,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
      category: 'Fast Food',
    ),
    FoodItem(
      id: '3',
      name: 'Chicken Salad',
      restaurant: 'Melt House',
      price: 4.56,
      rating: 4.6,
      reviewsCount: 890,
      calories: 32,
      deliveryTimeMin: 15,
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500',
      category: 'Fast Food',
    ),
  ];

  List<FoodItem> get foods => _foods;

  void addFoodItem(FoodItem item) {
    _foods.insert(0, item);
    notifyListeners();
  }

  void deleteFoodItem(String id) {
    _foods.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}