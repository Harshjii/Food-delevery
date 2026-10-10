import '../models/food_item.dart';

class CartItem {
  final String id;
  final FoodItem food;
  int quantity; // Mutable banaya hai taaki quantity++ aur -- kaam kare
  final String size;
  final List<Map<String, dynamic>> ingredients;

  CartItem({
    String? id,
    required this.food,
    this.quantity = 1,
    required this.size,
    required this.ingredients,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Getters jo Cart, Checkout, aur WhatsApp service me use ho rahe hain
  String get selectedSize => size;
  List<Map<String, dynamic>> get selectedIngredients => ingredients;

  // totalPrice aur totalItemPrice dono ke liye support
  double get totalPrice {
    double basePrice = food.sizePrices[size] ?? food.price;
    for (var ing in ingredients) {
      basePrice += (ing['price'] as num?)?.toDouble() ?? 0.0;
    }
    return basePrice * quantity;
  }

  double get totalItemPrice => totalPrice;
}