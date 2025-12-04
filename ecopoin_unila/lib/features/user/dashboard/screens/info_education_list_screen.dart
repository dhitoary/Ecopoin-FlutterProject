import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import 'education_detail_screen.dart';

class InfoEducationListScreen extends StatelessWidget {
  final List<Map<String, String>> items;

  const InfoEducationListScreen({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Info & Edukasi",
          style: TextStyle(color: AppColors.textDark),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                items[index]['title'] ?? "Info",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(items[index]['summary'] ?? ""),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EducationDetailScreen(
                      title: items[index]['title'] ?? '',
                      content:
                          items[index]['content'] ??
                          items[index]['summary'] ??
                          '',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
