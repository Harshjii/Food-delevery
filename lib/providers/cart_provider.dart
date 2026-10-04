import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => _items.isEmpty ? 0.0 : 5.0; // Flat delivery charge
  double get grandTotal => subtotal + deliveryFee;

  void addItem(FoodItem food, {String size = 'Medium', List<String> ingredients = const []}) {
    int index = _items.indexWhere((element) => element.food.id == food.id && element.size == size);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(food: food, size: size, ingredients: ingredients));
    }
    notifyListeners();
  }

  void incrementQuantity(int index) {
    _items[index].quantity++;
    notifyListeners();
  }

  void decrementQuantity(int index) {
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}