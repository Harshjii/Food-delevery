import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/food_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/menu_provider.dart';
import '../../services/auth_service.dart';
import '../admin/admin_panel_screen.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';
import 'food_detail_screen.dart';
import 'favorites_screen.dart';
import 'orders_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 1;

  // Filter states
  String _selectedFilterCategory = 'All';
  double _maxPriceFilter = 2000.0;
  String _searchQuery = '';

  // Secret Admin Password
  static const String _adminSecretPasscode = "zyvo@admin2026";

  final List<Map<String, dynamic>> _categories = [
    {'title': 'Meat', 'icon': '🥩'},
    {'title': 'Fast Food', 'icon': '🍔'},
    {'title': 'Sushi', 'icon': '🍣'},
    {'title': 'Drinks', 'icon': '🥤'},
  ];

  // Secret Admin Access Dialog
  void _openSecretAdminDialog() {
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.security, color: Color(0xFFFF5E00)),
            SizedBox(width: 8),
            Text("Admin Access 🔐", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter secret admin key to unlock dashboard:",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Secret Passcode",
                prefixIcon: const Icon(Icons.key, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5E00)),
            onPressed: () {
              if (passCtrl.text.trim() == _adminSecretPasscode) {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Incorrect Admin Passcode! ❌"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text("Verify", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // Filter Bottom Sheet with Price & Category
  void _showFilterBottomSheet() {
    String tempCategory = _selectedFilterCategory;
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
                  const Text(
                    'Filter Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Food Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: ['All', 'Meat', 'Fast Food', 'Sushi', 'Drinks'].map((category) {
                      return ChoiceChip(
                        label: Text(category),
                        selected: tempCategory == category,
                        selectedColor: const Color(0xFFFF5E00),
                        labelStyle: TextStyle(
                          color: tempCategory == category ? Colors.white : Colors.black87,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          setStateModal(() {
                            tempCategory = category;
                          });
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
                    onChanged: (value) {
                      setStateModal(() {
                        tempPrice = value;
                      });
                    },
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
                          _selectedFilterCategory = tempCategory;
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

  // Image Loader Widget
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
    const brandColor = Color(0xFFFF5E00);
    final cart = Provider.of<CartProvider>(context);
    final menuProv = Provider.of<MenuProvider>(context);

    // Filter logic based on search query, category, and price
    List<FoodItem> currentFoods = menuProv.foods.where((food) {
      final matchesSearch = food.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesPrice = food.price <= _maxPriceFilter;
      final matchesCategory = _selectedFilterCategory == 'All' ||
          food.category.toLowerCase() == _selectedFilterCategory.toLowerCase();
      return matchesSearch && matchesPrice && matchesCategory;
    }).toList();

    // Get user details
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    final firstName = (displayName != null && displayName.isNotEmpty)
        ? displayName.split(' ').first
        : (user?.email?.split('@'.trim()).first ?? 'Foodie');

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Secret Long-Press Logo (.jpeg extension fixed), Search, Filter & Notification Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onLongPress: _openSecretAdminDialog,
                    child: Image.asset(
                      'assets/images/logo.jpeg',
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
                  ),
                  Row(
                    children: [
                      // Search Icon
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.black87),
                        tooltip: "Search",
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: FoodSearchDelegate(menuProv.foods),
                          );
                        },
                      ),
                      // Filter Icon
                      IconButton(
                        icon: const Icon(Icons.tune, color: Colors.black87),
                        tooltip: "Filter",
                        onPressed: _showFilterBottomSheet,
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                        tooltip: "Notifications",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.black87),
                        tooltip: "Logout",
                        onPressed: () async {
                          await AuthService().signOut();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 14),

              // Dynamic Greeting
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, $firstName 👋",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "What would you like to eat today?",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 18),

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
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                          _selectedFilterCategory = _categories[index]['title'];
                        });
                      },
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

              // --- DYNAMIC COUPONS BANNER ---
              SizedBox(
                height: 150,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('coupons').where('isActive', isEqualTo: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: brandColor));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222629),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Special Offer", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  SizedBox(height: 4),
                                  Text("ZYVO SPECIAL", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Text("🛵🍕", style: TextStyle(fontSize: 50)),
                          ],
                        ),
                      );
                    }

                    final coupons = snapshot.data!.docs;

                    return PageView.builder(
                      itemCount: coupons.length,
                      itemBuilder: (context, index) {
                        final data = coupons[index].data() as Map<String, dynamic>;
                        final code = data['code'] ?? 'ZYVO';
                        final discount = data['discountPercent'] ?? 10;
                        final minOrder = data['minOrder'] ?? 199;

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: brandColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        code,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "$discount% OFF",
                                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Min. order ₹$minOrder • Limited Time Deal",
                                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const Text("🎁🍕", style: TextStyle(fontSize: 50)),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // --- Partner Restaurants ---
              const Text("Partner Restaurants", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              SizedBox(
                height: 160,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: brandColor));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No restaurants available right now.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      );
                    }

                    final restaurants = snapshot.data!.docs;

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: restaurants.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final data = restaurants[index].data() as Map<String, dynamic>;
                        final name = data['name'] ?? 'Restaurant';
                        final cuisine = data['cuisine'] ?? 'Fast Food';
                        final imageUrl = data['imageUrl'] ?? '';
                        final isOpen = data['isOpen'] ?? true;

                        return Container(
                          width: 140,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: imageUrl.isNotEmpty
                                    ? Image.network(imageUrl, width: double.infinity, height: 75, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 75,
                                      color: Colors.orange.shade50,
                                      child: const Icon(Icons.restaurant, color: brandColor),
                                    ))
                                    : Container(
                                  height: 75,
                                  color: Colors.orange.shade50,
                                  child: const Icon(Icons.restaurant, color: brandColor),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                cuisine,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isOpen ? '● Open' : '● Closed',
                                style: TextStyle(
                                  color: isOpen ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
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
              if (menuProv.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(color: brandColor),
                  ),
                )
              else if (currentFoods.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.restaurant_menu, size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text("No items match your filter/search.", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(color: brandColor, borderRadius: BorderRadius.circular(25)),
              child: const Row(
                children: [
                  Icon(Icons.home_filled, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text("Home", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border_rounded, color: Colors.grey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                );
              },
            ),
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
            IconButton(
              icon: const Icon(Icons.receipt_long_outlined, color: Colors.grey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Search Delegate Helper Class for Searching Food Items
class FoodSearchDelegate extends SearchDelegate<FoodItem?> {
  final List<FoodItem> foodList;

  FoodSearchDelegate(this.foodList);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = foodList.where((food) => food.name.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final food = results[index];
        return ListTile(
          leading: const Icon(Icons.fastfood, color: Color(0xFFFF5E00)),
          title: Text(food.name),
          subtitle: Text("Rs. ${food.price}"),
          onTap: () {
            close(context, food);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FoodDetailScreen(food: food)),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = foodList.where((food) => food.name.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final food = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search, color: Colors.grey, size: 20),
          title: Text(food.name),
          subtitle: Text("Rs. ${food.price} • ${food.category}"),
          onTap: () {
            query = food.name;
            showResults(context);
          },
        );
      },
    );
  }
}