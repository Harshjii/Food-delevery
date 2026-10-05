import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerTab extends StatelessWidget {
  const CustomerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Management',
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
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No registered customers found yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  final customers = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F6F9)),
                        columns: const [
                          DataColumn(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Joined Date', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: customers.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final customerId = doc.id;
                          final name = data['name'] ?? data['fullName'] ?? 'Foodie User';
                          final email = data['email'] ?? 'N/A';
                          final phone = data['phone'] ?? data['phoneNumber'] ?? 'N/A';

                          // Format timestamp if available
                          String joinedDate = 'N/A';
                          if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
                            DateTime dt = (data['createdAt'] as Timestamp).toDate();
                            joinedDate = "${dt.day}/${dt.month}/${dt.year}";
                          }

                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Color(0xFFFFF3ED),
                                      child: Icon(Icons.person, color: Color(0xFFFF5E00), size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              DataCell(Text(email)),
                              DataCell(Text(phone)),
                              DataCell(Text(joinedDate)),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  tooltip: 'Remove Customer Account',
                                  onPressed: () async {
                                    bool confirm = await _showDeleteConfirmation(context);
                                    if (confirm) {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(customerId)
                                          .delete();
                                    }
                                  },
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

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: const Text('Are you sure you want to remove this customer record?'),
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