import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/blogs_repository.dart';
import '../../../../data/services/api_client.dart';
import '../../../../domain/models/models.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';

class DoctorBlogsScreen extends StatefulWidget {
  const DoctorBlogsScreen({super.key});

  @override
  State<DoctorBlogsScreen> createState() => _DoctorBlogsScreenState();
}

class _DoctorBlogsScreenState extends State<DoctorBlogsScreen> {
  bool _isLoading = true;
  int _selectedTab = 0; // 0: All, 1: Published, 2: Under Review
  late BlogsRepository _repo;
  List<ArticleItem> _articles = [];

  static const _topics = [
    'Anxiety & Panic',
    'Depression & Mood',
    'Sleep Hygiene',
    'Stress Management',
    'Mindfulness & CBT',
  ];

  @override
  void initState() {
    super.initState();
    final apiClient = context.read<ApiClient>();
    _repo = BlogsRepository(apiClient);
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repo.getDoctorArticles();
      if (mounted) {
        setState(() {
          _articles = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteArticle(String id) async {
    final ok = await _repo.deleteArticle(id);
    if (!mounted) return;
    if (ok) {
      showHithaSnack(context, 'Article removed');
      _loadArticles();
    }
  }

  void _showNewArticleSheet() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedTopic = _topics.first;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Write Wellness Article',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: HithaColors.forest,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'TOPIC / SPECIALTY CATEGORY',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedTopic,
                        isExpanded: true,
                        items: _topics.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setSheetState(() => selectedTopic = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ARTICLE TITLE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'e.g. Cognitive Grounding for Panic Attacks',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ARTICLE BODY & CLINICAL ADVICE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: contentController,
                    maxLines: 5,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Provide evidence-based psychological insights, practical coping exercises...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Submit for Publication Review',
                    loading: isSubmitting,
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) {
                        showHithaSnack(context, 'Title is required', isError: true);
                        return;
                      }
                      if (contentController.text.trim().isEmpty) {
                        showHithaSnack(context, 'Content is required', isError: true);
                        return;
                      }

                      setSheetState(() => isSubmitting = true);
                      final ok = await _repo.createArticle(
                        title: titleController.text.trim(),
                        content: contentController.text.trim(),
                        topic: selectedTopic,
                        submitForReview: true,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        showHithaSnack(
                          context,
                          ok ? 'Article submitted for editorial review.' : 'Draft saved successfully.',
                        );
                        _loadArticles();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<ArticleItem> get _filteredArticles {
    if (_selectedTab == 1) {
      return _articles.where((a) => a.status.toUpperCase() == 'PUBLISHED').toList();
    } else if (_selectedTab == 2) {
      return _articles.where((a) => a.status.toUpperCase() != 'PUBLISHED').toList();
    }
    return _articles;
  }

  @override
  Widget build(BuildContext context) {
    final articles = _filteredArticles;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: HithaColors.forest),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'My Wellness Articles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: HithaColors.forest,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Psychoeducational publishing & community impact',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: HithaColors.forest, size: 21),
            onPressed: _loadArticles,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: HithaSegmentTab(
              tabs: const ['All', 'Published', 'In Review'],
              selectedIndex: _selectedTab,
              onTabSelected: (idx) => setState(() => _selectedTab = idx),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewArticleSheet,
        backgroundColor: HithaColors.forest,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.create, size: 18),
        label: const Text('Write Article', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HithaColors.forest))
          : RefreshIndicator(
              onRefresh: _loadArticles,
              color: HithaColors.forest,
              child: articles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.article_outlined, size: 40, color: Color(0xFF94A3B8)),
                          SizedBox(height: 10),
                          Text(
                            'No Articles Found',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Write and publish psychoeducational articles for mental health awareness.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                      itemCount: articles.length,
                      itemBuilder: (_, index) {
                        final article = articles[index];
                        final dateStr = DateFormat('MMM d, yyyy').format(article.publishedAt);

                        return HithaCard(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      article.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  HithaStatusBadge(status: article.status),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                article.excerpt,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule, size: 13, color: Color(0xFF94A3B8)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${article.readTimeMinutes} min read • $dateStr',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF94A3B8)),
                                    onPressed: () => _deleteArticle(article.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
