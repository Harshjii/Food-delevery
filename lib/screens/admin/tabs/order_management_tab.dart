import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderManagementTab extends StatelessWidget {
  const OrderManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E2D),
            ),
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
                        'No orders found.',
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
                          DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Restaurant', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: orders.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final orderId = doc.id;
                          final shortId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
                          final customerName = data['customerName'] ?? data['userName'] ?? 'N/A';
                          final restaurantName = data['restaurantName'] ?? 'N/A';
                          final amount = data['totalAmount'] ?? data['amount'] ?? 0;
                          final status = data['status'] ?? 'Pending';

                          Color statusColor;
                          switch (status.toString().toLowerCase()) {
                            case 'delivered':
                              statusColor = Colors.green;
                              break;
                            case 'preparing':
                              statusColor = Colors.orange;
                              break;
                            case 'out for delivery':
                              statusColor = Colors.blue;
                              break;
                            case 'cancelled':
                              statusColor = Colors.red;
                              break;
                            default:
                              statusColor = Colors.amber.shade800;
                          }

                          return DataRow(
                            cells: [
                              DataCell(Text('#$shortId', style: const TextStyle(fontWeight: FontWeight.w500))),
                              DataCell(Text(customerName)),
                              DataCell(Text(restaurantName)),
                              DataCell(Text('₹$amount', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: statusColor.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    status.toString().toUpperCase(),
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_note, color: Colors.deepOrange),
                                      tooltip: 'Update Status',
                                      onPressed: () {
                                        _showUpdateStatusDialog(context, orderId, status);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.visibility, color: Colors.blueGrey),
                                      tooltip: 'View Details',
                                      onPressed: () {
                                        _showOrderDetailsDialog(context, data, orderId);
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

  void _showUpdateStatusDialog(BuildContext context, String orderId, String currentStatus) {
    String selectedStatus = currentStatus;
    final statuses = ['Pending', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Order Status'),
              content: SizedBox(
                width: 300,
                child: DropdownButtonFormField<String>(
                  value: statuses.contains(selectedStatus) ? selectedStatus : 'Pending',
                  items: statuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedStatus = val!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(orderId)
                        .update({'status': selectedStatus});
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showOrderDetailsDialog(BuildContext context, Map<String, dynamic> data, String orderId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order Details (#${orderId.substring(0, 8)})'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer: ${data['customerName'] ?? data['userName'] ?? 'N/A'}'),
                  const SizedBox(height: 8),
                  Text('Restaurant: ${data['restaurantName'] ?? 'N/A'}'),
                  const SizedBox(height: 8),
                  Text('Total Amount: ₹${data['totalAmount'] ?? data['amount'] ?? 0}'),
                  const SizedBox(height: 8),
                  Text('Status: ${data['status'] ?? 'Pending'}'),
                  const SizedBox(height: 16),
                  const Text('Items Ordered:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...((data['items'] as List<dynamic>?)?.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text('• ${item['name'] ?? 'Item'} x ${item['quantity'] ?? 1} (₹${item['price'] ?? 0})'),
                    );
                  }) ?? [const Text('No item details available')])
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}