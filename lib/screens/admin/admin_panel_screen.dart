import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/food_item.dart';
import '../../providers/menu_provider.dart';
import '../../services/cloudinary_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _whatsappController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final menuProv = Provider.of<MenuProvider>(context, listen: false);
    _whatsappController.text = menuProv.adminWhatsAppNumber;
  }

  void _showAddFoodDialog() {
    final nameCtrl = TextEditingController();
    final restaurantCtrl = TextEditingController();

    // Size Price Controllers
    final smallPriceCtrl = TextEditingController(text: '150');
    final mediumPriceCtrl = TextEditingController(text: '250');
    final largePriceCtrl = TextEditingController(text: '350');

    final caloriesCtrl = TextEditingController(text: '45');
    final timeCtrl = TextEditingController(text: '20');

    // Ingredients Input List Controllers
    final ingredientNameCtrl = TextEditingController(text: 'Chicken (250 gm)');
    final ingredientPriceCtrl = TextEditingController(text: '120');

    File? selectedImageFile;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickImage(ImageSource source) async {
            final XFile? picked = await _picker.pickImage(
              source: source,
              imageQuality: 80,
            );
            if (picked != null) {
              setDialogState(() {
                selectedImageFile = File(picked.path);
              });
            }
          }

          final screenWidth = MediaQuery.of(context).size.width;
          const brandOrange = Color(0xFFFF5E00);

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Add New Food Item 🍔", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            content: SizedBox(
              width: screenWidth > 450 ? 450 : screenWidth * 0.85,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker Box
                    GestureDetector(
                      onTap: isUploading ? null : () {
                        showModalBottomSheet(
                          context: context,
                          builder: (sheetCtx) => SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Gallery se chunein'),
                                  onTap: () {
                                    Navigator.pop(sheetCtx);
                                    pickImage(ImageSource.gallery);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Camera se photo lein'),
                                  onTap: () {
                                    Navigator.pop(sheetCtx);
                                    pickImage(ImageSource.camera);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: selectedImageFile != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(selectedImageFile!, fit: BoxFit.cover, width: double.infinity),
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey[600]),
                            const SizedBox(height: 6),
                            Text(
                              "Tap to upload photo",
                              style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Dish Name")),
                    TextField(controller: restaurantCtrl, decoration: const InputDecoration(labelText: "Restaurant/Store Name")),

                    const SizedBox(height: 14),
                    const Text("Size Prices (Rs.)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: smallPriceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Small"))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: mediumPriceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Medium"))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: largePriceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Large"))),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Text("Default Addon / Ingredient", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Row(
                      children: [
                        Expanded(flex: 2, child: TextField(controller: ingredientNameCtrl, decoration: const InputDecoration(labelText: "Name (e.g. Chicken)"))),
                        const SizedBox(width: 8),
                        Expanded(flex: 1, child: TextField(controller: ingredientPriceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Extra Price"))),
                      ],
                    ),

                    const SizedBox(height: 14),
                    TextField(controller: caloriesCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Calories")),
                    TextField(controller: timeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Prep Time (mins)")),
                  ],
                ),
              ),
            ),
            actions: [
              if (!isUploading)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: brandOrange),
                onPressed: isUploading ? null : () async {
                  if (nameCtrl.text.isNotEmpty) {
                    setDialogState(() {
                      isUploading = true;
                    });

                    String finalImageUrl = 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500';

                    if (selectedImageFile != null) {
                      final uploadedUrl = await CloudinaryService.uploadImage(selectedImageFile!);
                      if (uploadedUrl != null) {
                        finalImageUrl = uploadedUrl;
                      }
                    }

                    // Sizes Map build karein
                    Map<String, double> sizePricesMap = {
                      'Small': double.tryParse(smallPriceCtrl.text) ?? 150.0,
                      'Medium': double.tryParse(mediumPriceCtrl.text) ?? 250.0,
                      'Large': double.tryParse(largePriceCtrl.text) ?? 350.0,
                    };

                    // Ingredients List build karein
                    List<Map<String, dynamic>> ingredientsList = [
                      {
                        'name': ingredientNameCtrl.text.trim().isEmpty ? 'Chicken (250 gm)' : ingredientNameCtrl.text.trim(),
                        'price': double.tryParse(ingredientPriceCtrl.text) ?? 120.0,
                      },
                      {
                        'name': 'Mashroom (50 gm)',
                        'price': 40.0,
                      }
                    ];

                    final newItem = FoodItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCtrl.text.trim(),
                      restaurant: restaurantCtrl.text.trim().isEmpty ? 'ZYVO Special' : restaurantCtrl.text.trim(),
                      price: sizePricesMap['Medium'] ?? 250.0,
                      rating: 4.8,
                      reviewsCount: 1,
                      calories: int.tryParse(caloriesCtrl.text) ?? 45,
                      deliveryTimeMin: int.tryParse(timeCtrl.text) ?? 20,
                      imageUrl: finalImageUrl,
                      category: 'Fast Food',
                      sizePrices: sizePricesMap,
                      ingredients: ingredientsList,
                    );

                    if (mounted) {
                      Navigator.pop(ctx);
                      await Provider.of<MenuProvider>(context, listen: false).addFoodItem(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Item Added with Sizes & Ingredients! ✅"), backgroundColor: brandOrange),
                      );
                    }
                  }
                },
                child: isUploading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text("Add to Menu", style: TextStyle(color: Colors.white)),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildFoodImage(String path, {double size = 60}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(Icons.fastfood, size: size * 0.6, color: const Color(0xFFFF5E00)),
      );
    } else {
      return Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(Icons.fastfood, size: size * 0.6, color: const Color(0xFFFF5E00)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFFF5E00);
    final menuProv = Provider.of<MenuProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Admin Dashboard 🛠️", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Order Receiving WhatsApp Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  const Text("Customer ka order aur location is number par bhejte hain.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _whatsappController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "91XXXXXXXXXX",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: brandOrange),
                        onPressed: () {
                          menuProv.updateWhatsAppNumber(_whatsappController.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("WhatsApp Number Updated! ✅"), backgroundColor: brandOrange),
                          );
                        },
                        child: const Text("Save", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Manage Food Menu (${menuProv.foods.length})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text("Add Item", style: TextStyle(color: Colors.white)),
                  onPressed: _showAddFoodDialog,
                )
              ],
            ),
            const SizedBox(height: 12),
            if (menuProv.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: brandOrange),
                ),
              )
            else if (menuProv.foods.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text("Menu is empty. Add your first item!", style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: menuProv.foods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final food = menuProv.foods[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _buildFoodImage(food.imageUrl, size: 60),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text("${food.restaurant} • Rs. ${food.price}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              Text("${food.calories} cal | ${food.deliveryTimeMin} min", style: const TextStyle(fontSize: 11, color: brandOrange)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            menuProv.deleteFoodItem(food.id);
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}