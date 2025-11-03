import 'package:flutter/material.dart';
import 'history_item_card.dart';

class HistoryDepositTab extends StatelessWidget {
  const HistoryDepositTab({super.key});

  // Data dummy dari HTML
  final List<Map<String, String>> historyData = const [
    {
      "date": "12 Mei 2024",
      "status": "Selesai",
      "type": "Plastik",
      "points": "+100 Poin",
    },
    {
      "date": "10 Mei 2024",
      "status": "Ditolak",
      "type": "Kertas",
      "points": "+0 Poin",
    },
    {
      "date": "8 Mei 2024",
      "status": "Menunggu",
      "type": "Logam",
      "points": "+0 Poin",
    },
    {
      "date": "5 Mei 2024",
      "status": "Selesai",
      "type": "Kaca",
      "points": "+75 Poin",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: historyData.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final item = historyData[index];
        return HistoryItemCard(
          date: item['date']!,
          status: item['status']!,
          type: item['type']!,
          points: item['points']!,
        );
      },
    );
  }
}
