import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  // --- COUPON VARIABLES ---
  double _discountPercent = 0.0;
  String? _appliedCouponCode;

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => _items.isEmpty ? 0.0 : 5.0; // Flat delivery charge

  // --- DISCOUNT & TOTAL GETTERS ---
  double get discountPercent => _discountPercent;
  String? get appliedCouponCode => _appliedCouponCode;

  double get discountAmount => subtotal * (_discountPercent / 100);
  double get grandTotal => (subtotal - discountAmount) + deliveryFee;

  // --- COUPON METHODS ---
  Future<bool> applyCoupon(String code) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('coupons')
          .where('code', isEqualTo: code.trim().toUpperCase())
          .where('isActive', isEqualTo: true)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        final double minOrder = (data['minOrder'] ?? 0).toDouble();

        if (subtotal >= minOrder) {
          _discountPercent = (data['discountPercent'] ?? 0).toDouble();
          _appliedCouponCode = data['code'];
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void removeCoupon() {
    _discountPercent = 0.0;
    _appliedCouponCode = null;
    notifyListeners();
  }

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
    _discountPercent = 0.0;
    _appliedCouponCode = null;
    notifyListeners();
  }
}