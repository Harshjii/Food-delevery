import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item.dart';

class FavoritesProvider with ChangeNotifier {
  final List<FoodItem> _favoriteItems = [];
  bool _isLoading = false;

  List<FoodItem> get favoriteItems => _favoriteItems;
  bool get isLoading => _isLoading;

  FavoritesProvider() {
    fetchFavorites();
  }

  // Firebase se favorites load karna
  Future<void> fetchFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      _favoriteItems.clear();
      for (var doc in snapshot.docs) {
        _favoriteItems.add(FoodItem.fromMap(doc.data(), doc.id));
      }
    } catch (e) {
      debugPrint("Error fetching favorites: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Check karna ki item already favorite hai ya nahi
  bool isFavorite(FoodItem item) {
    return _favoriteItems.any((element) => element.id == item.id);
  }

  // Toggle Favorite (Firebase me Add / Remove karna)
  Future<void> toggleFavorite(FoodItem item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    if (isFavorite(item)) {
      _favoriteItems.removeWhere((element) => element.id == item.id);
      try {
        await favRef.doc(item.id).delete();
      } catch (e) {
        debugPrint("Error removing favorite: $e");
      }
    } else {
      _favoriteItems.add(item);
      try {
        await favRef.doc(item.id).set(item.toMap());
      } catch (e) {
        debugPrint("Error adding favorite: $e");
      }
    }
    notifyListeners();
  }
}