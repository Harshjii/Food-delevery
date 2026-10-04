import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cart_item.dart';

class WhatsAppService {
  static Future<bool> sendOrder({
    required String adminNumber,
    required String customerName,
    required String customerPhone,
    required String addressNotes,
    required List<CartItem> cartItems,
    required double totalAmount,
    required Position position,
  }) async {
    final String itemsSummary = cartItems.map((item) {
      return "• ${item.food.name} (${item.size}) x${item.quantity} = \Rs. ${item.totalPrice.toStringAsFixed(2)}";
    }).join("\n");

    final String mapsLink = "https://maps.google.com/?q=${position.latitude},${position.longitude}";

    final String message = """
🛍️ *NEW FOOD ORDER*
--------------------------------
👤 *Customer:* $customerName
📞 *Phone:* $customerPhone
🏠 *Notes:* $addressNotes

🛒 *Items Ordered:*
$itemsSummary

💵 *Total Amount:* \Rs. ${totalAmount.toStringAsFixed(2)}

📍 *Live Delivery Location:*
$mapsLink
--------------------------------
_Awaiting payment confirmation._
""";

    final Uri url = Uri.parse(
      "https://wa.me/$adminNumber?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(url)) {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      return false;
    }
  }
}