import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../services/article_service.dart';
import 'education_detail_screen.dart';

class InfoEducationListScreen extends StatelessWidget {
  // Constructor tidak perlu parameter list lagi
  const InfoEducationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArticleService articleService = ArticleService();

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
      // Gunakan StreamBuilder untuk data Real-time
      body: StreamBuilder<List<ArticleModel>>(
        stream: articleService.getArticlesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final articles = snapshot.data ?? [];

          if (articles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada artikel edukasi",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
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
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[100],
                      child:
                          article.imageUrl != null &&
                              article.imageUrl!.isNotEmpty
                          ? Image.network(
                              article.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => const Icon(
                                Icons.article,
                                color: AppColors.primary,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(12),
                              color: AppColors.primary.withOpacity(0.1),
                              child: const Icon(
                                Icons.article_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                    ),
                  ),
                  title: Text(
                    article.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      article.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EducationDetailScreen(
                          title: article.title,
                          content: article.content.isNotEmpty
                              ? article.content
                              : article.summary,
                          // Jika Anda ingin mengirim URL gambar ke detail screen,
                          // pastikan EducationDetailScreen menerima parameter imageUrl
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
