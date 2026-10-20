import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import 'food_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFFFF5E00);
    final favoritesProv = Provider.of<FavoritesProvider>(context);
    final favItems = favoritesProv.favoriteItems;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text("My Favorites ❤️", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: favItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            const Text("No favorites added yet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text("Tap the heart icon on any dish to save it here.", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favItems.length,
        itemBuilder: (context, index) {
          final food = favItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  food.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.orange.shade50,
                    child: const Icon(Icons.fastfood, color: brandColor),
                  ),
                ),
              ),
              title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Text("Rs. ${food.price}", style: const TextStyle(color: brandColor, fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  favoritesProv.toggleFavorite(food);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FoodDetailScreen(food: food)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}