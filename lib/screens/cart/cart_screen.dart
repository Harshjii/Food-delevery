import 'dart:io'; // <-- 1. File support ke liye import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'checkout_dialog.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // Helper widget jo device file aur network URL dono render karta hai
  Widget _buildCartImage(String path, {double size = 70}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 36, color: Color(0xFF53B175)),
      );
    } else {
      return Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 36, color: Color(0xFF53B175)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF53B175);
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text("Cart", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black87),
            onPressed: () => cart.clearCart(),
          ),
        ],
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text("Your cart is empty! 🍔", style: TextStyle(fontSize: 16, color: Colors.grey)))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => Divider(color: Colors.grey[200], height: 24),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      // 2. Helper widget use kiya device image support ke liye
                      child: _buildCartImage(item.food.imageUrl, size: 70),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(item.food.restaurant, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                          const SizedBox(height: 6),
                          Text("\$${item.totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => cart.decrementQuantity(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.remove, size: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        GestureDetector(
                          onTap: () => cart.incrementQuantity(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: brandGreen, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    )
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Promo Code Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.percent_rounded, size: 18, color: Colors.grey),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Promo code",
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    child: const Text("Apply", style: TextStyle(fontSize: 12, color: Colors.white)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bill Breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Subtotal", style: TextStyle(color: Colors.grey)),
                Text("\$${cart.subtotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Delivery", style: TextStyle(color: Colors.grey)),
                Text("\$${cart.deliveryFee.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("\$${cart.grandTotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brandGreen)),
              ],
            ),
            const SizedBox(height: 30),

            // Checkout Action Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => const CheckoutBottomSheet(),
                  );
                },
                child: Text(
                  "Checkout  •  \$${cart.grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}