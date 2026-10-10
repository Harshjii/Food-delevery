import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food_item.dart';
import '../../providers/menu_provider.dart';
import 'food_detail_screen.dart';

class AllFoodsScreen extends StatefulWidget {
  const AllFoodsScreen({super.key});

  @override
  State<AllFoodsScreen> createState() => _AllFoodsScreenState();
}

class _AllFoodsScreenState extends State<AllFoodsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  double _maxPriceFilter = 2000.0;

  // Filter Bottom Sheet
  void _showFilterBottomSheet() {
    String tempCategory = _selectedCategory;
    double tempPrice = _maxPriceFilter;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Food Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: ['All', 'Meat', 'Fast Food', 'Sushi', 'Drinks'].map((cat) {
                      return ChoiceChip(
                        label: Text(cat),
                        selected: tempCategory == cat,
                        selectedColor: const Color(0xFFFF5E00),
                        labelStyle: TextStyle(color: tempCategory == cat ? Colors.white : Colors.black87, fontSize: 12),
                        onSelected: (selected) {
                          setStateModal(() => tempCategory = cat);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('Max Price (Rs. ${tempPrice.round()})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Slider(
                    value: tempPrice,
                    min: 50.0,
                    max: 2000.0,
                    divisions: 39,
                    activeColor: const Color(0xFFFF5E00),
                    onChanged: (value) => setStateModal(() => tempPrice = value),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5E00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCategory = tempCategory;
                          _maxPriceFilter = tempPrice;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildItemImage(String path, {double size = 90}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.cover, width: size, height: size,
          errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 40, color: Color(0xFFFF5E00)));
    } else {
      return Image.file(File(path), fit: BoxFit.cover, width: size, height: size,
          errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 40, color: Color(0xFFFF5E00)));
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFFFF5E00);
    final menuProv = Provider.of<MenuProvider>(context);

    // Filter logic
    List<FoodItem> filteredFoods = menuProv.foods.where((food) {
      final matchesSearch = food.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesPrice = food.price <= _maxPriceFilter;
      final matchesCategory = _selectedCategory == 'All' || food.category.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesPrice && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("All Food Menu 🍔", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black87),
            tooltip: "Filter",
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search dishes...",
                prefixIcon: const Icon(Icons.search, color: brandColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Food Grid
          Expanded(
            child: menuProv.isLoading
                ? const Center(child: CircularProgressIndicator(color: brandColor))
                : filteredFoods.isEmpty
                ? const Center(child: Text("No items found.", style: TextStyle(color: Colors.grey)))
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredFoods.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                final food = filteredFoods[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FoodDetailScreen(food: food)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text("Rs. ${food.price}", style: const TextStyle(color: brandColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: _buildItemImage(food.imageUrl, size: 90),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department, size: 14, color: Colors.deepOrangeAccent),
                            Text(" ${food.calories} Calories", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}