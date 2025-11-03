import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class ScheduleDepositTab extends StatefulWidget {
  const ScheduleDepositTab({super.key});

  @override
  State<ScheduleDepositTab> createState() => _ScheduleDepositTabState();
}

class _ScheduleDepositTabState extends State<ScheduleDepositTab> {
  String? _selectedJenis;
  String? _selectedBerat;
  String? _selectedMetode;

  final List<String> _jenisOptions = [
    'Kertas',
    'Plastik',
    'Logam',
    'Kaca',
    'Organik',
    'Lainnya',
  ];
  final List<String> _beratOptions = ['<1kg', '1-5kg', '>5kg'];
  final List<String> _metodeOptions = ['Drop-off', 'Minta Penjemputan'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Jenis Sampah
          _buildSectionHeader("Jenis Sampah"),
          _buildChoiceChipGroup(
            options: _jenisOptions,
            selectedValue: _selectedJenis,
            onSelected: (value) {
              setState(() => _selectedJenis = value);
            },
          ),

          // Form Estimasi Berat
          _buildSectionHeader("Estimasi Berat"),
          _buildChoiceChipGroup(
            options: _beratOptions,
            selectedValue: _selectedBerat,
            onSelected: (value) {
              setState(() => _selectedBerat = value);
            },
          ),

          // Form Metode
          _buildSectionHeader("Metode"),
          _buildChoiceChipGroup(
            options: _metodeOptions,
            selectedValue: _selectedMetode,
            onSelected: (value) {
              setState(() => _selectedMetode = value);
            },
          ),

          // Tombol Ajukan Setoran
          // HTML: <button class="...flex-1 bg-[#13e76b]...">
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Logika pengajuan setoran (development: debug print)
                debugPrint(
                  "Jenis: $_selectedJenis, Berat: $_selectedBerat, Metode: $_selectedMetode",
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textDark,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Ajukan Setoran",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Helper untuk Judul Section
  // HTML: <h3 class="...text-lg font-bold...">
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper untuk grup ChoiceChip
  // HTML: <div class="flex flex-wrap gap-3 p-4">
  Widget _buildChoiceChipGroup({
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: options.map((option) {
          final isSelected = selectedValue == option;
          // HTML: <label class="...border...has-[:checked]:border-[3px]...">
          return ChoiceChip(
            label: Text(option),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected) {
                onSelected(option);
              }
            },
            labelStyle: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            backgroundColor: AppColors.background,
            selectedColor: AppColors.inputBackground, // Warna saat dipilih
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              // HTML: has-[:checked]:border-[#13e76b]
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          );
        }).toList(),
      ),
    );
  }
}
