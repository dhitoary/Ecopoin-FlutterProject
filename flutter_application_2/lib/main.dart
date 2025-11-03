import 'package:flutter/material.dart';

import 'classification_screen.dart';
import 'schedule_screen.dart';
import 'rewards_screen.dart';

void main() {
  runApp(const EcoPoinApp());
}

class EcoPoinApp extends StatelessWidget {
  const EcoPoinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoPoin Unila',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(title: 'EcoPoin Unila'),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  Widget _buildFeatureButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap, // onTap akan diisi di bawah
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(icon, size: 30, color: Colors.green.shade700),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.lightGreen.shade50,
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          children: <Widget>[
            Icon(Icons.star, color: Colors.amber, size: 40),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('EcoPoin Anda', style: TextStyle(fontSize: 16)),
                Text(
                  '1.250 Poin',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionStatus() {
    return const ListTile(
      leading: Icon(Icons.check_circle, color: Colors.green),
      title: Text('Penjemputan Sampah Berikutnya'),
      subtitle: Text('Selasa, 28 Oktober 2025, jam 09:00'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildPointsCard(context),
            const SizedBox(height: 20),
            Text(
              'Layanan Cepat',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildFeatureButton(
                  context,
                  icon: Icons.search,
                  label: 'Klasifikasi',
                  // DIUBAH: Menambahkan aksi navigasi
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClassificationScreen(),
                      ),
                    );
                  },
                ),
                _buildFeatureButton(
                  context,
                  icon: Icons.calendar_month,
                  label: 'Jadwal',
                  // DIUBAH: Menambahkan aksi navigasi
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScheduleScreen(),
                      ),
                    );
                  },
                ),
                _buildFeatureButton(
                  context,
                  icon: Icons.redeem,
                  label: 'Tukar Poin',
                  // DIUBAH: Menambahkan aksi navigasi
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RewardsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Status Penjemputan',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildCollectionStatus(),
            const Divider(height: 30),
            Text(
              'Info EcoPoin',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(
                Icons.lightbulb_outline,
                color: Colors.orange,
              ),
              title: const Text('Cara Mendaur Ulang Plastik PET'),
              subtitle: const Text(
                'Cari tahu ide kreatif untuk botol plastik.',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
