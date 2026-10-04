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
  });
}