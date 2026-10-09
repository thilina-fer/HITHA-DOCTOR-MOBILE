import '../../domain/models/models.dart';
import '../services/api_client.dart';

class BlogsRepository {
  BlogsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ArticleItem>> getDoctorArticles() async {
    try {
      final res = await _apiClient.get('/blogs', query: {'page': '0', 'size': '20'});
      List rawList = [];
      if (res is Map<String, dynamic> && res['content'] is List) {
        rawList = res['content'] as List;
      } else if (res is List) {
        rawList = res;
      }
      return rawList.map((e) => ArticleItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> createArticle({
    required String title,
    required String content,
    required String topic,
    bool submitForReview = true,
  }) async {
    try {
      final slug = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
      await _apiClient.post('/blogs', {
        'title': title.trim(),
        'slug': slug.isNotEmpty ? slug : 'article-${DateTime.now().millisecondsSinceEpoch}',
        'content': content.trim(),
        'topic': topic.trim(),
        'submitForReview': submitForReview,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteArticle(String id) async {
    try {
      await _apiClient.delete('/blogs/$id');
      return true;
    } catch (_) {
      return false;
    }
  }
}
