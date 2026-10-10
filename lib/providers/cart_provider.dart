import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  // Coupon & Discount States
  String? _appliedCouponCode;
  double _discountPercent = 0.0;

  List<CartItem> get items => [..._items];

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get deliveryFee => _items.isEmpty ? 0.0 : 5.0;

  // Getters for Coupon & Discount
  String? get appliedCouponCode => _appliedCouponCode;
  double get discountPercent => _discountPercent;
  double get discountAmount => subtotal * (_discountPercent / 100);

  double get grandTotal {
    double total = subtotal + deliveryFee - discountAmount;
    return total < 0 ? 0.0 : total;
  }

  // Add item to cart
  void addItem(FoodItem food, {String size = 'Medium', List<Map<String, dynamic>> ingredients = const []}) {
    final existingIndex = _items.indexWhere((item) =>
    item.food.id == food.id &&
        item.size == size &&
        listEquals(item.ingredients, ingredients)
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(
        CartItem(
          food: food,
          size: size,
          ingredients: ingredients,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  // Increment Quantity by Index (used in cart_screen.dart)
  void incrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // Decrement Quantity by Index (used in cart_screen.dart)
  void decrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Coupon Management Methods
  Future<bool> applyCoupon(String code) async {
    final cleanCode = code.toUpperCase().trim();
    if (cleanCode == 'ZYVO50') {
      _appliedCouponCode = cleanCode;
      _discountPercent = 50.0; // 50% discount
      notifyListeners();
      return true;
    } else if (cleanCode == 'WELCOME20') {
      _appliedCouponCode = cleanCode;
      _discountPercent = 20.0; // 20% discount
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCoupon() {
    _appliedCouponCode = null;
    _discountPercent = 0.0;
    notifyListeners();
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    removeCoupon();
    notifyListeners();
  }
}