import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantTab extends StatefulWidget {
  const RestaurantTab({super.key});

  @override
  State<RestaurantTab> createState() => _RestaurantTabState();
}

class _RestaurantTabState extends State<RestaurantTab> {
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
                'Restaurant Management',
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
                icon: const Icon(Icons.add),
                label: const Text('Add Restaurant'),
                onPressed: () {
                  _showAddRestaurantDialog(context);
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
                stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No restaurants found. Click "Add Restaurant" to create one.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  final restaurants = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F6F9)),
                        columns: const [
                          DataColumn(label: Text('Logo', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Restaurant Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Cuisine / Category', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: restaurants.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final restId = doc.id;
                          final name = data['name'] ?? 'N/A';
                          final cuisine = data['cuisine'] ?? data['category'] ?? 'Fast Food';
                          final phone = data['phone'] ?? 'N/A';
                          final imageUrl = data['imageUrl'] ?? '';
                          final isOpen = data['isOpen'] ?? true;

                          return DataRow(
                            cells: [
                              DataCell(
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(imageUrl, width: 40, height: 40, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: Colors.grey))
                                      : Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.restaurant, color: Colors.grey, size: 20),
                                  ),
                                ),
                              ),
                              DataCell(Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(cuisine)),
                              DataCell(Text(phone)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isOpen ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    isOpen ? 'OPEN' : 'CLOSED',
                                    style: TextStyle(
                                      color: isOpen ? Colors.green : Colors.red,
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
                                        isOpen ? Icons.toggle_on : Icons.toggle_off,
                                        color: isOpen ? Colors.green : Colors.grey,
                                        size: 28,
                                      ),
                                      tooltip: 'Toggle Open/Close',
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('restaurants')
                                            .doc(restId)
                                            .update({'isOpen': !isOpen});
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      tooltip: 'Delete Restaurant',
                                      onPressed: () async {
                                        bool confirm = await _showDeleteConfirmation(context);
                                        if (confirm) {
                                          await FirebaseFirestore.instance
                                              .collection('restaurants')
                                              .doc(restId)
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

  void _showAddRestaurantDialog(BuildContext context) {
    final nameController = TextEditingController();
    final cuisineController = TextEditingController();
    final phoneController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Restaurant'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Restaurant Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cuisineController,
                    decoration: const InputDecoration(labelText: 'Cuisine / Category', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: imageController,
                    decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
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
                if (nameController.text.trim().isNotEmpty) {
                  await FirebaseFirestore.instance.collection('restaurants').add({
                    'name': nameController.text.trim(),
                    'cuisine': cuisineController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'imageUrl': imageController.text.trim(),
                    'isOpen': true,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add'),
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
          title: const Text('Delete Restaurant'),
          content: const Text('Are you sure you want to delete this restaurant?'),
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