import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CouponTab extends StatelessWidget {
  const CouponTab({super.key});

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
                'Coupons & Promos Management',
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
                icon: const Icon(Icons.local_offer),
                label: const Text('Create Coupon'),
                onPressed: () {
                  _showCreateCouponDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                stream: FirebaseFirestore.instance.collection('coupons').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No promotional coupons found. Click "Create Coupon" to add one.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  final coupons = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F6F9)),
                        columns: const [
                          DataColumn(label: Text('Coupon Code', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Discount', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Min. Order (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: coupons.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final couponId = doc.id;
                          final code = data['code'] ?? 'ZYVO20';
                          final discount = data['discountPercent'] ?? data['discount'] ?? 10;
                          final minOrder = data['minOrder'] ?? 199;
                          final isActive = data['isActive'] ?? true;

                          return DataRow(
                            cells: [
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF5E00).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFFF5E00).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    code.toString().toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF5E00)),
                                  ),
                                ),
                              ),
                              DataCell(Text('$discount%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                              DataCell(Text('₹$minOrder')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isActive ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    isActive ? 'ACTIVE' : 'EXPIRED',
                                    style: TextStyle(
                                      color: isActive ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isActive ? Icons.toggle_on : Icons.toggle_off,
                                        color: isActive ? Colors.green : Colors.grey,
                                        size: 28,
                                      ),
                                      tooltip: 'Toggle Active Status',
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('coupons')
                                            .doc(couponId)
                                            .update({'isActive': !isActive});
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      tooltip: 'Delete Coupon',
                                      onPressed: () async {
                                        bool confirm = await _showDeleteConfirmation(context);
                                        if (confirm) {
                                          await FirebaseFirestore.instance
                                              .collection('coupons')
                                              .doc(couponId)
                                              .delete();
                                        }
                                      },
                                    ),
                                  ],
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

  void _showCreateCouponDialog(BuildContext context) {
    final codeController = TextEditingController();
    final discountController = TextEditingController();
    final minOrderController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Promo Code'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Coupon Code (e.g. WELCOME50)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Discount Percentage (%)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: minOrderController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Minimum Order Amount (₹)', border: OutlineInputBorder()),
                  ),
                ],
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
              onPressed: () async {
                if (codeController.text.trim().isNotEmpty && discountController.text.trim().isNotEmpty) {
                  await FirebaseFirestore.instance.collection('coupons').add({
                    'code': codeController.text.trim().toUpperCase(),
                    'discountPercent': double.tryParse(discountController.text.trim()) ?? 10.0,
                    'minOrder': double.tryParse(minOrderController.text.trim()) ?? 199.0,
                    'isActive': true,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Coupon'),
          content: const Text('Are you sure you want to delete this promotional coupon?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ) ??
        false;
  }
}