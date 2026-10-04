import 'food_item.dart';

class CartItem {
  final FoodItem food;
  final String size;
  final List<String> ingredients;
  int quantity;

  CartItem({
    required this.food,
    this.size = 'Medium',
    this.ingredients = const [],
    this.quantity = 1,
  });

  double get totalPrice => food.price * quantity;
}