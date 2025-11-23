import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../services/firestore_service.dart';

class ScheduleDepositTab extends StatefulWidget {
  const ScheduleDepositTab({super.key});

  @override
  State<ScheduleDepositTab> createState() => _ScheduleDepositTabState();
}

class _ScheduleDepositTabState extends State<ScheduleDepositTab> {
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  String? _selectedType;
  bool _isLoading = false;

  final List<String> _trashTypes = [
    'Plastik (Botol/Gelas)',
    'Kertas/Karton',
    'Logam/Kaleng',
    'Elektronik (E-Waste)',
    'Minyak Jelantah',
  ];

  int _calculatePoints(String type, double weight) {
    int pointsPerKg = 100;
    if (type.contains('Plastik')) pointsPerKg = 200;
    if (type.contains('Logam')) pointsPerKg = 300;
    if (type.contains('Elektronik')) pointsPerKg = 500;
    return (weight * pointsPerKg).toInt();
  }

  void _handleSubmit() async {
    if (_selectedType == null || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi data jenis dan berat sampah"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Ganti koma jadi titik, dan parsing aman
      String weightText = _weightController.text.replaceAll(',', '.');
      double? weight = double.tryParse(weightText);

      if (weight == null) {
        throw Exception(
          "Format berat tidak valid. Gunakan angka (contoh: 2.5)",
        );
      }

      int points = _calculatePoints(_selectedType!, weight);

      await _firestoreService.submitDeposit(
        type: _selectedType!,
        weight: weight,
        note: _noteController.text,
        pointsEarned: points,
      );

      if (mounted) {
        _weightController.clear();
        _noteController.clear();
        setState(() => _selectedType = null);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Berhasil! 🎉"),
            content: Text("Setoran dijadwalkan. Estimasi +$points Poin!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Poin otomatis masuk setelah tombol ditekan.",
                    style: TextStyle(fontSize: 12, color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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
            ),
            items: _trashTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => setState(() => _selectedType = value),
          ),
          const SizedBox(height: 16),

          const Text(
            "Perkiraan Berat (Kg)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: "Contoh: 2.5",
              suffixText: "kg",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            "Catatan Lokasi",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "Lokasi detail...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Jadwalkan & Dapat Poin",
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
