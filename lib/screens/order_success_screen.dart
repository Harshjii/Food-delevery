import 'package:flutter/material.dart';
import 'home/home_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF53B175);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: brandGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, size: 75, color: brandGreen),
              ),
              const SizedBox(height: 32),
              const Text(
                "Order Confirmed!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                "Your details & GPS location have been sent to WhatsApp.\nYour meal will be arriving shortly!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                    );
                  },
                  child: const Text("Back to Home", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}