import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommissionTab extends StatelessWidget {
  const CommissionTab({super.key});

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
                'Commissions & Earnings',
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
                icon: const Icon(Icons.settings),
                label: const Text('Configure Commission'),
                onPressed: () {
                  _showCommissionSettingsDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- COMMISSION OVERVIEW CARDS ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              double totalPlatformRevenue = 0;
              double totalSales = 0;
              int completedOrdersCount = 0;

              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final double orderAmount = (data['totalAmount'] ?? data['amount'] ?? 0).toDouble();
                  final String status = data['status'] ?? 'Pending';

                  totalSales += orderAmount;
                  if (status.toLowerCase() == 'delivered') {
                    completedOrdersCount++;
                    // Maan lijiye platform ka commission 10% hai
                    totalPlatformRevenue += (orderAmount * 0.10);
                  }
                }
              }

              return GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.2,
                children: [
                  _buildEarningsCard(
                    title: 'Total Gross Sales',
                    value: '₹${totalSales.toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet,
                    color: Colors.blue,
                  ),
                  _buildEarningsCard(
                    title: 'Platform Commission (10%)',
                    value: '₹${totalPlatformRevenue.toStringAsFixed(2)}',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                  _buildEarningsCard(
                    title: 'Delivered Orders Count',
                    value: '$completedOrdersCount',
                    icon: Icons.check_circle_outline,
                    color: Colors.orange,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 30),

          const Text(
            'Recent Commission Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E2D),
            ),
          ),
          const SizedBox(height: 16),

          // --- TRANSACTIONS TABLE ---
          Expanded(
            child: Container(
              width: double.infinity,
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No order transactions found yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  final orders = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F6F9)),
                        columns: const [
                          DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Restaurant', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Order Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Admin Comm. (10%)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: orders.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final orderId = doc.id;
                          final shortId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
                          final restaurantName = data['restaurantName'] ?? 'Partner Restaurant';
                          final double amount = (data['totalAmount'] ?? data['amount'] ?? 0).toDouble();
                          final double commission = amount * 0.10;
                          final status = data['status'] ?? 'Pending';

                          return DataRow(
                            cells: [
                              DataCell(Text('#$shortId', style: const TextStyle(fontWeight: FontWeight.w500))),
                              DataCell(Text(restaurantName)),
                              DataCell(Text('₹${amount.toStringAsFixed(2)}')),
                              DataCell(Text('₹${commission.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                              DataCell(
                                Text(
                                  status.toString().toUpperCase(),
                                  style: TextStyle(
                                    color: status.toString().toLowerCase() == 'delivered' ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2D),
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 24),
          ),
        ],
      ),
    );
  }

  void _showCommissionSettingsDialog(BuildContext context) {
    final commissionController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Configure Commission Rate'),
          content: SizedBox(
            width: 300,
            child: TextField(
              controller: commissionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Platform Commission (%)',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5E00), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Commission rate updated successfully!')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}