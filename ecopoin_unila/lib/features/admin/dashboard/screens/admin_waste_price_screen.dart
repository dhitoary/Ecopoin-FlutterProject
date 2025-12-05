import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../services/waste_price_service.dart';

class AdminWastePriceScreen extends StatelessWidget {
  const AdminWastePriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WastePriceService wastePriceService = WastePriceService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Atur Harga Poin",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: wastePriceService.getWasteTypesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada data tipe sampah."));
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;
              final name = data['name'] ?? '-';
              final points = data['points'] ?? 0;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(
                      Icons.recycling,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("$points Poin / kg"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showFormDialog(
                          context,
                          wastePriceService,
                          id: id,
                          currentName: name,
                          currentPoints: points,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmDelete(context, wastePriceService, id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showFormDialog(context, wastePriceService),
        label: const Text("Tambah Tipe"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // Dialog Form (Tambah / Edit)
  void _showFormDialog(
    BuildContext context,
    WastePriceService service, {
    String? id,
    String? currentName,
    int? currentPoints,
  }) {
    final nameController = TextEditingController(text: currentName);
    final pointsController = TextEditingController(
      text: currentPoints?.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? "Tambah Tipe Sampah" : "Edit Tipe Sampah"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nama Tipe (misal: Plastik)",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pointsController,
              decoration: const InputDecoration(labelText: "Poin per Kg"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final points = int.tryParse(pointsController.text.trim()) ?? 0;

              if (name.isNotEmpty && points > 0) {
                if (id == null) {
                  service.addWasteType(name, points);
                } else {
                  service.updateWasteType(id, name, points);
                }
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WastePriceService service,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus?"),
        content: const Text("Yakin ingin menghapus tipe sampah ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              service.deleteWasteType(id);
              Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
