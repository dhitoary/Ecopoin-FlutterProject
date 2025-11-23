import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class ScheduleDepositTab extends StatefulWidget {
  const ScheduleDepositTab({super.key});

  @override
  State<ScheduleDepositTab> createState() => _ScheduleDepositTabState();
}

class _ScheduleDepositTabState extends State<ScheduleDepositTab> {
  // Controller form
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedType;

  final List<String> _trashTypes = [
    'Plastik (Botol/Gelas)',
    'Kertas/Karton',
    'Logam/Kaleng',
    'Elektronik (E-Waste)',
    'Minyak Jelantah',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Pastikan sampah sudah dipilah dan dibersihkan sebelum disetor.",
                    style: TextStyle(fontSize: 12, color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1. Pilih Jenis Sampah
          const Text(
            "Jenis Sampah",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              hintText: "Pilih kategori sampah",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: _trashTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) => setState(() => _selectedType = value),
          ),
          const SizedBox(height: 16),

          // 2. Estimasi Berat
          const Text(
            "Perkiraan Berat (Kg)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Contoh: 2.5",
              suffixText: "kg",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Catatan Tambahan
          const Text(
            "Catatan / Lokasi Penjemputan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Misal: Di depan Gedung G, Teknik Informatika...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Kirim
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Nanti kita sambungkan ke backend
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Fitur setor akan segera aktif!"),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Jadwalkan Penjemputan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
