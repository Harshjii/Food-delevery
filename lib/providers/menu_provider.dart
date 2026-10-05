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

  // Firestore se real-time menu stream using FoodItem.fromFirestore factory
  void _listenToMenuUpdates() {
    _firestore.collection('foods').snapshots().listen((snapshot) {
      _foods = snapshot.docs.map((doc) {
        return FoodItem.fromFirestore(doc);
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

  // Firestore me naya item add karna (Size prices aur ingredients ke sath)
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
      'sizePrices': food.sizePrices, // Save sizes Map
      'ingredients': food.ingredients, // Save ingredients List
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Firestore se item delete karna
  Future<void> deleteFoodItem(String id) async {
    await _firestore.collection('foods').doc(id).delete();
  }
}