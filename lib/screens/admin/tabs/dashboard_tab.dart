import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E2D),
            ),
          ),
          const SizedBox(height: 20),

          // --- STATS CARDS SECTION ---
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> orderSnapshot) {
              if (orderSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              int totalOrders = orderSnapshot.hasData ? orderSnapshot.data!.docs.length : 0;

              double totalRevenue = 0;
              if (orderSnapshot.hasData) {
                for (var doc in orderSnapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  totalRevenue += (data['totalAmount'] ?? 0).toDouble();
                }
              }

              return StreamBuilder(
                stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> restSnapshot) {
                  int totalRestaurants = restSnapshot.hasData ? restSnapshot.data!.docs.length : 0;

                  return StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('riders').snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> riderSnapshot) {
                      int totalRiders = riderSnapshot.hasData ? riderSnapshot.data!.docs.length : 0;

                      return GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Fixed here
                        childAspectRatio: 1.5,
                        children: [
                          _buildStatCard(
                            title: 'Total Orders',
                            value: '$totalOrders',
                            icon: Icons.shopping_bag_outlined,
                            color: Colors.blue,
                          ),
                          _buildStatCard(
                            title: 'Total Revenue',
                            value: '₹${totalRevenue.toStringAsFixed(2)}',
                            icon: Icons.currency_rupee,
                            color: Colors.green,
                          ),
                          _buildStatCard(
                            title: 'Active Restaurants',
                            value: '$totalRestaurants',
                            icon: Icons.restaurant,
                            color: Colors.orange,
                          ),
                          _buildStatCard(
                            title: 'Delivery Riders',
                            value: '$totalRiders',
                            icon: Icons.delivery_dining,
                            color: Colors.purple,
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 40),

          // --- RECENT ORDERS SECTION ---
          const Text(
            'Recent Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E2D),
            ),
          ),
          const SizedBox(height: 16),
          Container(
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
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: Text('No recent orders found.')),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Fixed here
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final order = snapshot.data!.docs[index];
                    final data = order.data() as Map<String, dynamic>;

                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFF5E00),
                        child: Icon(Icons.fastfood, color: Colors.white, size: 18),
                      ),
                      title: Text('Order ID: ${order.id.substring(0, 8)}...'),
                      subtitle: Text('Status: ${data['status'] ?? 'Pending'}'),
                      trailing: Text(
                        '₹${data['totalAmount'] ?? 0}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
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

  Widget _buildStatCard({
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E2D),
            ),
          ),
        ],
      ),
    );
  }
}