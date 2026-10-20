import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  bool _isLoading = false;

  // Coupon & Discount States
  String? _appliedCouponCode;
  double _discountPercent = 0.0;

  List<CartItem> get items => [..._items];
  bool get isLoading => _isLoading;

  CartProvider() {
    fetchCart();
  }

  // Firebase se Cart fetch karna
  Future<void> fetchCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      _items.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();

        // FoodItem maping
        final foodMap = data['food'] as Map<String, dynamic>? ?? {};
        final foodItem = FoodItem.fromMap(foodMap, foodMap['id'] ?? doc.id);

        _items.add(
          CartItem(
            id: doc.id,
            food: foodItem,
            size: data['size'] ?? 'Medium',
            ingredients: List<Map<String, dynamic>>.from(data['ingredients'] ?? []),
            quantity: data['quantity'] ?? 1,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error fetching cart: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

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

  // Fixed syntax error here
  double get discountAmount => subtotal * (_discountPercent / 100);

  double get grandTotal {
    // Fixed syntax error here
    double total = subtotal + deliveryFee - discountAmount;
    return total < 0 ? 0.0 : total;
  }

  // Add item to cart & sync with Firebase
  Future<void> addItem(FoodItem food, {String size = 'Medium', List<Map<String, dynamic>> ingredients = const []}) async {
    final user = FirebaseAuth.instance.currentUser;

    final existingIndex = _items.indexWhere((item) =>
    item.food.id == food.id &&
        item.size == size &&
        listEquals(item.ingredients, ingredients)
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
      if (user != null) {
        final cartId = _items[existingIndex].id;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(cartId)
            .update({'quantity': _items[existingIndex].quantity});
      }
    } else {
      final newItem = CartItem(
        food: food,
        size: size,
        ingredients: ingredients,
        quantity: 1,
      );
      _items.add(newItem);

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(newItem.id)
            .set({
          'id': newItem.id,
          'food': {
            'id': food.id,
            'name': food.name,
            'price': food.price,
            'imageUrl': food.imageUrl,
            'category': food.category,
            'restaurant': food.restaurant,
            'rating': food.rating,
            'reviewsCount': food.reviewsCount,
            'calories': food.calories,
            'deliveryTimeMin': food.deliveryTimeMin,
            'sizePrices': food.sizePrices,
            'ingredients': food.ingredients,
          },
          'size': size,
          'ingredients': ingredients,
          'quantity': newItem.quantity,
        });
      }
    }
    notifyListeners();
  }

  // Increment Quantity by Index
  Future<void> incrementQuantity(int index) async {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity++;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(_items[index].id)
            .update({'quantity': _items[index].quantity});
      }
    }
  }

  // Decrement Quantity by Index
  Future<void> decrementQuantity(int index) async {
    if (index >= 0 && index < _items.length) {
      final user = FirebaseAuth.instance.currentUser;
      final cartItemId = _items[index].id;

      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        notifyListeners();

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('cart')
              .doc(cartItemId)
              .update({'quantity': _items[index].quantity});
        }
      } else {
        _items.removeAt(index);
        notifyListeners();

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('cart')
              .doc(cartItemId)
              .delete();
        }
      }
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

  Future<void> removeItem(String cartItemId) async {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(cartItemId)
            .delete();
      } catch (e) {
        debugPrint("Error removing cart item: $e");
      }
    }
  }

  Future<void> clearCart() async {
    final user = FirebaseAuth.instance.currentUser;

    // Local clear
    _items.clear();
    removeCoupon();
    notifyListeners();

    // Firebase clear
    if (user != null) {
      try {
        final cartSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .get();

        for (var doc in cartSnapshot.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint("Error clearing cart from Firebase: $e");
      }
    }
  }
}