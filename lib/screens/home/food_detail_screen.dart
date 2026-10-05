import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food_item.dart';
import '../../providers/cart_provider.dart';
import '../cart/cart_screen.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem food;
  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;
  late String _selectedSize;
  final List<Map<String, dynamic>> _selectedIngredients = [];

  @override
  void initState() {
    super.initState();
    // Default size set karein jo admin ne dala ho
    if (widget.food.sizePrices.isNotEmpty) {
      _selectedSize = widget.food.sizePrices.keys.first;
    } else {
      _selectedSize = 'Medium';
    }
  }

  // Dynamic price calculation: (Size Price + Extra Ingredients Price) * Quantity
  double get _calculatedTotalPrice {
    double basePrice = widget.food.sizePrices[_selectedSize] ?? widget.food.price;
    for (var ing in _selectedIngredients) {
      basePrice += (ing['price'] as num?)?.toDouble() ?? 0.0;
    }
    return basePrice * _quantity;
  }

  // Helper widget to render Device photo or Network URL
  Widget _buildDetailImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        height: 210,
        width: 210,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 80, color: Color(0xFF53B175)),
      );
    } else {
      return Image.file(
        File(path),
        height: 210,
        width: 210,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 80, color: Color(0xFF53B175)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF53B175);
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border, color: Colors.black87), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black87), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(105),
                child: _buildDetailImage(widget.food.imageUrl),
              ),
            ),
            const SizedBox(height: 24),
            Text(widget.food.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text("🍕 ", style: TextStyle(fontSize: 14)),
                Text(widget.food.restaurant, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(width: 14),
                const Icon(Icons.star_rounded, size: 18, color: brandGreen),
                Text(" ${widget.food.rating} (${widget.food.reviewsCount}k)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 24),

            // --- DYNAMIC SIZES SELECTOR ---
            if (widget.food.sizePrices.isNotEmpty) ...[
              const Text("Select Size", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: widget.food.sizePrices.entries.map((entry) {
                  final sizeName = entry.key;
                  final sizePrice = entry.value;
                  final isSelected = _selectedSize == sizeName;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedSize = sizeName),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                          border: Border.all(color: isSelected ? brandGreen : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, size: 18, color: isSelected ? brandGreen : Colors.grey),
                            const SizedBox(height: 6),
                            Text(sizeName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                            const SizedBox(height: 4),
                            Text("Rs. $sizePrice", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // --- DYNAMIC INGREDIENTS LIST ---
            if (widget.food.ingredients.isNotEmpty) ...[
              const Text("Add Ingredients", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.food.ingredients.length,
                itemBuilder: (context, index) {
                  final ing = widget.food.ingredients[index];
                  final ingName = ing['name'] ?? '';
                  final ingPrice = (ing['price'] as num?)?.toDouble() ?? 0.0;
                  final isChecked = _selectedIngredients.any((item) => item['name'] == ingName);

                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: brandGreen,
                    value: isChecked,
                    title: Text(ingName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text("+Rs. $ingPrice", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    onChanged: (bool? val) {
                      setState(() {
                        if (val == true) {
                          _selectedIngredients.add(ing);
                        } else {
                          _selectedIngredients.removeWhere((item) => item['name'] == ingName);
                        }
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Text("$_quantity", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    for (int i = 0; i < _quantity; i++) {
                      cart.addItem(
                        widget.food,
                        size: _selectedSize,
                        ingredients: List.from(_selectedIngredients),
                      );
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                  },
                  child: Text(
                    "Add to Cart  •  Rs. ${_calculatedTotalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}