import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reports & Analytics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2D),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5E00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.download),
                label: const Text('Export CSV Report'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report export feature simulated successfully! 📊')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- REAL-TIME METRICS STREAM ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').snapshots(),
              builder: (context, orderSnapshot) {
                if (orderSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                int totalOrders = 0;
                int deliveredOrders = 0;
                int cancelledOrders = 0;
                double grossRevenue = 0;

                if (orderSnapshot.hasData) {
                  totalOrders = orderSnapshot.data!.docs.length;
                  for (var doc in orderSnapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final double amount = (data['totalAmount'] ?? data['amount'] ?? 0).toDouble();
                    final String status = (data['status'] ?? 'Pending').toString().toLowerCase();

                    grossRevenue += amount;
                    if (status == 'delivered') {
                      deliveredOrders++;
                    } else if (status == 'cancelled') {
                      cancelledOrders++;
                    }
                  }
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, userSnapshot) {
                    int totalUsers = userSnapshot.hasData ? userSnapshot.data!.docs.length : 0;

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
                      builder: (context, restSnapshot) {
                        int totalRestaurants = restSnapshot.hasData ? restSnapshot.data!.docs.length : 0;

                        return ListView(
                          children: [
                            // Summary Cards Grid
                            GridView.count(
                              crossAxisCount: 4,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 1.4,
                              children: [
                                _buildReportCard('Total Gross Revenue', '₹${grossRevenue.toStringAsFixed(2)}', Icons.currency_rupee, Colors.green),
                                _buildReportCard('Total Order Volume', '$totalOrders', Icons.shopping_bag, Colors.blue),
                                _buildReportCard('Registered Customers', '$totalUsers', Icons.group, Colors.purple),
                                _buildReportCard('Partner Restaurants', '$totalRestaurants', Icons.restaurant, Colors.orange),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Order Performance Breakdown Container
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Order Status Distribution',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D)),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildProgressBar('Successfully Delivered', deliveredOrders, totalOrders, Colors.green),
                                  const SizedBox(height: 14),
                                  _buildProgressBar('Cancelled Orders', cancelledOrders, totalOrders, Colors.red),
                                  const SizedBox(height: 14),
                                  _buildProgressBar('Pending / Processing', totalOrders - deliveredOrders - cancelledOrders, totalOrders, Colors.amber),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int count, int total, Color color) {
    double percentage = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text('$count (${(percentage * 100).toStringAsFixed(1)}%)', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 10,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}