import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';

class InfoEducationListScreen extends StatefulWidget {
  final List<Map<String, String>> items;

  const InfoEducationListScreen({super.key, required this.items});

  @override
  State<InfoEducationListScreen> createState() =>
      _InfoEducationListScreenState();
}

class _InfoEducationListScreenState extends State<InfoEducationListScreen> {
  static const int pageSize = 5;
  int currentPage = 1;

  int get pageCount => (widget.items.length / pageSize).ceil();

  List<Map<String, String>> pageItems(int page) {
    final start = (page - 1) * pageSize;
    return widget.items.skip(start).take(pageSize).toList();
  }

  @override
  Widget build(BuildContext context) {
    final itemsOnPage = pageItems(currentPage);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Info & Edukasi',
          style: TextStyle(color: AppColors.textDark),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: itemsOnPage.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                itemBuilder: (context, idx) {
                  final it = itemsOnPage[idx];
                  return Card(
                    child: ListTile(
                      title: Text(it['title'] ?? ''),
                      subtitle: Text(it['summary'] ?? ''),
                    ),
                  );
                },
              ),
            ),

            // Simple pagination controls (prev/next)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: currentPage > 1
                      ? () => setState(() => currentPage--)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                const SizedBox(width: 8.0),
                Text('Halaman $currentPage dari $pageCount'),
                const SizedBox(width: 8.0),
                IconButton(
                  onPressed: currentPage < pageCount
                      ? () => setState(() => currentPage++)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),

            const SizedBox(height: 8.0),

            // Page number buttons (allow jump-to-page)
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              alignment: WrapAlignment.center,
              children: List<Widget>.generate(pageCount, (i) {
                final page = i + 1;
                final isCurrent = page == currentPage;
                return SizedBox(
                  width: 40,
                  height: 36,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isCurrent ? AppColors.primary : null,
                      foregroundColor: isCurrent ? AppColors.textDark : null,
                    ),
                    onPressed: () => setState(() => currentPage = page),
                    child: Text('$page'),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
