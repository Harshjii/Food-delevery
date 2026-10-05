import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryBoyTab extends StatelessWidget {
  const DeliveryBoyTab({super.key});

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
                'Delivery Riders Management',
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
                icon: const Icon(Icons.person_add),
                label: const Text('Add Rider'),
                onPressed: () {
                  _showAddRiderDialog(context);
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
                stream: FirebaseFirestore.instance.collection('riders').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No delivery riders found. Click "Add Rider" to register one.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  final riders = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F6F9)),
                        columns: const [
                          DataColumn(label: Text('Rider Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Vehicle Number', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: riders.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final riderId = doc.id;
                          final name = data['name'] ?? 'N/A';
                          final phone = data['phone'] ?? 'N/A';
                          final vehicle = data['vehicleNumber'] ?? data['vehicle'] ?? 'Bike';
                          final isOnline = data['isOnline'] ?? true;

                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Color(0xFFFFF3ED),
                                      child: Icon(Icons.delivery_dining, color: Color(0xFFFF5E00), size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              DataCell(Text(phone)),
                              DataCell(Text(vehicle)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isOnline ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isOnline ? Colors.green.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    isOnline ? 'ACTIVE' : 'OFFLINE',
                                    style: TextStyle(
                                      color: isOnline ? Colors.green : Colors.grey.shade700,
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
                                        isOnline ? Icons.toggle_on : Icons.toggle_off,
                                        color: isOnline ? Colors.green : Colors.grey,
                                        size: 28,
                                      ),
                                      tooltip: 'Toggle Active/Offline',
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('riders')
                                            .doc(riderId)
                                            .update({'isOnline': !isOnline});
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      tooltip: 'Remove Rider',
                                      onPressed: () async {
                                        bool confirm = await _showDeleteConfirmation(context);
                                        if (confirm) {
                                          await FirebaseFirestore.instance
                                              .collection('riders')
                                              .doc(riderId)
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

  void _showAddRiderDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final vehicleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Delivery Rider'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Rider Full Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: vehicleController,
                    decoration: const InputDecoration(labelText: 'Vehicle Number (e.g. UP85 AB 1234)', border: OutlineInputBorder()),
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
                if (nameController.text.trim().isNotEmpty && phoneController.text.trim().isNotEmpty) {
                  await FirebaseFirestore.instance.collection('riders').add({
                    'name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'vehicleNumber': vehicleController.text.trim(),
                    'isOnline': true,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Register'),
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
          title: const Text('Remove Rider'),
          content: const Text('Are you sure you want to remove this delivery rider?'),
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