import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';

class MenuProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<FoodItem> _foods = [];
  String _adminWhatsAppNumber = "919876543210";
  bool _isLoading = true;

  List<FoodItem> get foods => [..._foods];
  String get adminWhatsAppNumber => _adminWhatsAppNumber;
  bool get isLoading => _isLoading;

  MenuProvider() {
    _listenToMenuUpdates();
    _fetchWhatsAppNumber();
  }

  // Firestore se real-time menu stream
  void _listenToMenuUpdates() {
    _firestore.collection('foods').snapshots().listen((snapshot) {
      _foods = snapshot.docs.map((doc) {
        final data = doc.data();
        return FoodItem(
          id: doc.id,
          name: data['name'] ?? '',
          restaurant: data['restaurant'] ?? 'ZYVO Kitchen',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
          reviewsCount: data['reviewsCount'] ?? 1,
          calories: data['calories'] ?? 45,
          deliveryTimeMin: data['deliveryTimeMin'] ?? 20,
          imageUrl: data['imageUrl'] ?? 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500',
          category: data['category'] ?? 'Fast Food',
        );
      }).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  // Admin WhatsApp setting read karna
  Future<void> _fetchWhatsAppNumber() async {
    try {
      final doc = await _firestore.collection('settings').doc('admin_config').get();
      if (doc.exists && doc.data() != null) {
        _adminWhatsAppNumber = doc.data()!['whatsapp_number'] ?? _adminWhatsAppNumber;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching settings: $e");
    }
  }

  // Admin WhatsApp setting save karna
  Future<void> updateWhatsAppNumber(String newNumber) async {
    _adminWhatsAppNumber = newNumber;
    notifyListeners();
    await _firestore.collection('settings').doc('admin_config').set({
      'whatsapp_number': newNumber,
    }, SetOptions(merge: true));
  }

  // Firestore me naya item add karna
  Future<void> addFoodItem(FoodItem food) async {
    await _firestore.collection('foods').doc(food.id).set({
      'name': food.name,
      'restaurant': food.restaurant,
      'price': food.price,
      'rating': food.rating,
      'reviewsCount': food.reviewsCount,
      'calories': food.calories,
      'deliveryTimeMin': food.deliveryTimeMin,
      'imageUrl': food.imageUrl,
      'category': food.category,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Firestore se item delete karna
  Future<void> deleteFoodItem(String id) async {
    await _firestore.collection('foods').doc(id).delete();
  }
}