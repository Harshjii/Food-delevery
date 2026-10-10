import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/cart_provider.dart';
import '../../providers/menu_provider.dart';
import '../../services/location_service.dart';
import '../../services/whatsapp_service.dart';
import '../order_success_screen.dart';

class CheckoutBottomSheet extends StatefulWidget {
  const CheckoutBottomSheet({super.key});

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  Position? _currentPosition;
  bool _isFetchingLocation = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      _nameController.text = user.displayName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserLocation() async {
    setState(() => _isFetchingLocation = true);

    final pos = await LocationService.determinePosition();
    if (pos != null) {
      setState(() {
        _currentPosition = pos;
        if (_addressController.text.trim().isEmpty) {
          _addressController.text = "GPS: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}";
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("📍 Current GPS location captured!"),
            backgroundColor: Color(0xFFFF5E00),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission allow karni hogi.")),
        );
      }
    }

    setState(() => _isFetchingLocation = false);
  }

  void _processWhatsAppOrder() async {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill your Name and Phone Number.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    Position? pos = _currentPosition;
    pos ??= await LocationService.determinePosition();

    if (pos == null) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location capture karna zaroori hai delivery ke liye.")),
        );
      }
      return;
    }

    final cart = Provider.of<CartProvider>(context, listen: false);
    final menuProv = Provider.of<MenuProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        await FirebaseFirestore.instance.collection('orders').add({
          'userId': user.uid,
          'userEmail': user.email ?? '',
          'customerName': _nameController.text.trim(),
          'customerPhone': _phoneController.text.trim(),
          'address': _addressController.text.trim().isEmpty
              ? "GPS: ${pos.latitude}, ${pos.longitude}"
              : _addressController.text.trim(),
          'totalAmount': cart.grandTotal,
          'status': 'Placed',
          'createdAt': FieldValue.serverTimestamp(),
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'items': cart.items.map((item) => {
            'id': item.food.id,
            'name': item.food.name,
            'size': item.selectedSize,
            'ingredients': item.selectedIngredients,
            'price': item.totalItemPrice / item.quantity,
            'quantity': item.quantity,
            'imageUrl': item.food.imageUrl,
          }).toList(),
        });
      }
    } catch (e) {
      debugPrint("Error saving order to Firestore: $e");
    }

    final success = await WhatsAppService.sendOrder(
      adminNumber: menuProv.adminWhatsAppNumber,
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      addressNotes: _addressController.text.trim().isEmpty ? "Near live GPS location" : _addressController.text.trim(),
      cartItems: cart.items,
      totalAmount: cart.grandTotal,
      position: pos,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        cart.clearCart();
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("WhatsApp could not be opened. Check if WhatsApp is installed.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFFF5E00);
    final menuProv = Provider.of<MenuProvider>(context);
    final cart = Provider.of<CartProvider>(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Delivery & Payment 🛵", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (_currentPosition != null)
                  const Chip(
                    label: Text("GPS Locked 🎯", style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    backgroundColor: brandOrange,
                    padding: EdgeInsets.zero,
                  )
              ],
            ),
            const SizedBox(height: 6),
            Text("Enter details and complete payment via UPI QR below.", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 18),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Your Full Name",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Contact Phone Number",
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: _isFetchingLocation ? null : _fetchUserLocation,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: brandOrange.withOpacity(0.08),
                  border: Border.all(color: brandOrange.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _isFetchingLocation
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: brandOrange))
                        : const Icon(Icons.my_location_rounded, color: brandOrange, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentPosition == null ? "Tap to fetch Current GPS Location 📍" : "Location Captured ✓ (Tap to refresh)",
                        style: const TextStyle(color: brandOrange, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: "Address / Flat / Landmark",
                prefixIcon: const Icon(Icons.home_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),

            // --- UPI QR CODE & PAYMENT INSTRUCTIONS SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  const Text("Scan QR to Pay via UPI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text("Total Amount: Rs. ${cart.grandTotal.toStringAsFixed(2)}", style: const TextStyle(color: brandOrange, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),

                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: menuProv.adminUpiQrUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(menuProv.adminUpiQrUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
                      ),
                    )
                        : const Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "⚠️ Please send the payment screenshot on WhatsApp after clicking confirm for fast order confirmation!",
                    style: TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: (_isSubmitting || _isFetchingLocation) ? null : _processWhatsAppOrder,
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Confirm & Send via WhatsApp 📲", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}