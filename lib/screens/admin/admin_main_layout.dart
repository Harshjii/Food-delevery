import 'package:flutter/material.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/order_management_tab.dart';
import 'tabs/restaurant_tab.dart';
import 'tabs/delivery_boy_tab.dart';
import 'tabs/customer_tab.dart';
import 'tabs/commission_tab.dart';
import 'tabs/reports_tab.dart';
import 'tabs/coupon_tab.dart';
import 'tabs/banner_tab.dart';
import 'tabs/notification_tab.dart';
import 'tabs/settings_tab.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    DashboardTab(),
    OrderManagementTab(),
    RestaurantTab(),
    DeliveryBoyTab(),
    CustomerTab(),
    CommissionTab(),
    ReportsTab(),
    CouponTab(),
    BannerTab(),
    NotificationTab(),
    SettingsTab(),
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard},
    {'title': 'Orders', 'icon': Icons.shopping_bag},
    {'title': 'Restaurants', 'icon': Icons.restaurant},
    {'title': 'Delivery Boys', 'icon': Icons.delivery_dining},
    {'title': 'Customers', 'icon': Icons.people},
    {'title': 'Commissions', 'icon': Icons.account_balance_wallet},
    {'title': 'Reports', 'icon': Icons.bar_chart},
    {'title': 'Coupons', 'icon': Icons.local_offer},
    {'title': 'Banners', 'icon': Icons.view_carousel},
    {'title': 'Notifications', 'icon': Icons.notifications},
    {'title': 'Settings', 'icon': Icons.settings},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 260,
            color: const Color(0xFF1E1E2D),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: const [
                      Icon(Icons.flash_on, color: Colors.deepOrange, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'ZYVO Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      final isSelected = _selectedIndex == index;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepOrange : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Icon(
                            item['icon'],
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                          title: Text(
                            item['title'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _menuItems[_selectedIndex]['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: const [
                          CircleAvatar(
                            backgroundColor: Colors.deepOrange,
                            child: Text('A', style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Super Admin',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'admin@zyvo.com',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF4F6F9),
                    child: _tabs[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}