import 'package:flutter/material.dart';

// ==========================================
// 1. APP INFO & STRINGS
// ==========================================
const String appName = 'ZYVO';
const String appTagline = 'Fresh food awaits you.';

// ==========================================
// 2. CURRENCY & PRICING
// ==========================================
const String currencySymbol = '₹'; // Ya 'Rs. ' jo aapko pasand ho
const double deliveryCharge = 30.0;
const double platformFee = 5.0;

// ==========================================
// 3. WHATSAPP & CONTACT DETAILS
// ==========================================
// WhatsApp order notification number (Country code ke sath, bina '+' ya space ke)
const String adminWhatsAppNumber = '919876543210';
const String supportEmail = 'adminzyvo1234@gmail.com';

// ==========================================
// 4. FIRESTORE COLLECTION NAMES
// ==========================================
// Typos se bachne ke liye Firestore collections ke constants
class AppCollections {
  static const String users = 'users';
  static const String foods = 'foods';
  static const String orders = 'orders';
  static const String categories = 'categories';
}

// ==========================================
// 5. APP THEME COLORS
// ==========================================
class AppColors {
  static const Color primary = Color(0xFFFF5722);    // Orange primary
  static const Color primaryDark = Color(0xFFE64A19);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
}

// ==========================================
// 6. DEFAULT PADDINGS & RADII
// ==========================================
const double defaultPadding = 16.0;
const double defaultRadius = 12.0;