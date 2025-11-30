import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Bantuan & Dukungan',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hubungi Kami",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildContactRow(
                    Icons.email,
                    "Email Support",
                    "admin@ecopoin.unila.ac.id",
                  ),
                  const Divider(),
                  _buildContactRow(
                    Icons.phone,
                    "WhatsApp Center",
                    "+62 812-3456-7890",
                  ),
                  const Divider(),
                  _buildContactRow(
                    Icons.map,
                    "Lokasi Kantor",
                    "Gedung A, Universitas Lampung",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Pertanyaan Umum (FAQ)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              "Bagaimana cara menambah kategori sampah?",
              "Masuk ke menu Rewards/Sampah di dashboard, lalu pilih 'Tambah Kategori'.",
            ),
            _buildFaqItem(
              "Berapa lama proses verifikasi?",
              "Idealnya verifikasi dilakukan dalam 1x24 jam setelah mahasiswa melakukan setoran.",
            ),
            _buildFaqItem(
              "Bagaimana jika stok reward habis?",
              "Anda dapat memperbarui stok melalui menu 'Manajemen Rewards' dengan mengedit item terkait.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
