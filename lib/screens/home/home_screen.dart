import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/menu_provider.dart';
import '../admin/admin_panel_screen.dart';
import '../cart/cart_screen.dart';
import 'food_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 1;

  final List<Map<String, dynamic>> _categories = [
    {'title': 'Meat', 'icon': '🥩'},
    {'title': 'Fast Food', 'icon': '🍔'},
    {'title': 'Sushi', 'icon': '🍣'},
    {'title': 'Drinks', 'icon': '🥤'},
  ];

  // Helper widget jo URL aur Device File dono handle karta hai
  Widget _buildItemImage(String path, {double size = 90}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 40, color: Color(0xFFFF5E00)),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 40, color: Color(0xFFFF5E00)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ZYVO signature primary orange
    const brandColor = Color(0xFFFF5E00);
    final cart = Provider.of<CartProvider>(context);
    final menuProv = Provider.of<MenuProvider>(context);
    final List<FoodItem> currentFoods = menuProv.foods;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header with ZYVO Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 38,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      "ZYVO",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: brandColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search_rounded, color: Colors.black87),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
                        onPressed: () {},
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),

              // Categories Row
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedCategoryIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryIndex = index),
                      child: Column(
                        children: [
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFFF3ED) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? brandColor : Colors.grey.shade200,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(_categories[index]['icon'], style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _categories[index]['title'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),

              // Offer Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF222629),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("New Year Offer", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          const Text(
                            "30% OFF",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          const Text("16 - 31 Dec", style: TextStyle(color: Colors.white54, fontSize: 11)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                            onPressed: () {},
                            child: const Text("Get Now", style: TextStyle(fontSize: 12, color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                    const Text("🛵🍕", style: TextStyle(fontSize: 55)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Best Sellers Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Best Sellers (${currentFoods.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("See All", style: TextStyle(color: brandColor, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),

              // Food Grid Cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentFoods.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final food = currentFoods[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FoodDetailScreen(food: food)),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(food.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text("\$${food.price}", style: const TextStyle(color: brandColor, fontWeight: FontWeight.bold, fontSize: 14)),
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
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                  Text(" ${food.deliveryTimeMin} min", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  cart.addItem(food);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("${food.name} added to cart!"), duration: const Duration(milliseconds: 700)),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: brandColor, borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: brandColor, borderRadius: BorderRadius.circular(25)),
              child: const Row(
                children: [
                  Icon(Icons.home_filled, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text("Home", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.favorite_border_rounded, color: Colors.grey), onPressed: () {}),
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.grey),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                  },
                ),
                if (cart.itemCount > 0)
                  CircleAvatar(
                    radius: 8,
                    backgroundColor: brandColor,
                    child: Text('${cart.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
            IconButton(icon: const Icon(Icons.receipt_long_outlined, color: Colors.grey), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.grey),
              tooltip: "Admin Dashboard",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}