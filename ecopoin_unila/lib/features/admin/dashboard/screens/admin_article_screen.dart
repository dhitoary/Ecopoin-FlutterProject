import 'package:flutter/material.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../services/article_service.dart';

class AdminArticleScreen extends StatelessWidget {
  const AdminArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArticleService articleService = ArticleService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Manajemen Edukasi",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<ArticleModel>>(
        stream: articleService.getArticlesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Belum ada artikel. Klik (+) untuk buat."),
            );
          }

          final articles = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: articles.length,
            separatorBuilder: (ctx, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child:
                          article.imageUrl != null &&
                              article.imageUrl!.isNotEmpty
                          ? Image.network(article.imageUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.article, color: Colors.grey),
                    ),
                  ),
                  title: Text(
                    article.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showArticleForm(
                          context,
                          articleService,
                          article: article,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmDelete(context, articleService, article.id),
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
        onPressed: () => _showArticleForm(context, articleService),
        label: const Text("Tulis Artikel"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // Form Dialog (Tambah/Edit)
  void _showArticleForm(
    BuildContext context,
    ArticleService service, {
    ArticleModel? article,
  }) {
    final titleCtrl = TextEditingController(text: article?.title);
    final summaryCtrl = TextEditingController(text: article?.summary);
    final contentCtrl = TextEditingController(text: article?.content);
    final imageCtrl = TextEditingController(text: article?.imageUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(article == null ? "Artikel Baru" : "Edit Artikel"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Judul",
                  hintText: "Misal: Cara Pilah Sampah",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: summaryCtrl,
                decoration: const InputDecoration(
                  labelText: "Ringkasan",
                  hintText: "Muncul di daftar depan",
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageCtrl,
                decoration: const InputDecoration(
                  labelText: "URL Gambar (Opsional)",
                  hintText: "https://...",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(
                  labelText: "Isi Lengkap",
                  hintText: "Tulis edukasi lengkap di sini...",
                ),
                maxLines: 6,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && contentCtrl.text.isNotEmpty) {
                if (article == null) {
                  service.addArticle(
                    title: titleCtrl.text,
                    summary: summaryCtrl.text,
                    content: contentCtrl.text,
                    imageUrl: imageCtrl.text,
                  );
                } else {
                  service.updateArticle(
                    id: article.id,
                    title: titleCtrl.text,
                    summary: summaryCtrl.text,
                    content: contentCtrl.text,
                    imageUrl: imageCtrl.text,
                  );
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

  void _confirmDelete(BuildContext context, ArticleService service, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Artikel?"),
        content: const Text("Data yang dihapus tidak bisa dikembalikan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              service.deleteArticle(id);
              Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
