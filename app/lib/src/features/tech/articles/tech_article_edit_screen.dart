import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:portfolio_admin/src/components/auth_required_state.dart';
import 'package:portfolio_admin/src/features/tech/eyecatch.dart';
import 'package:portfolio_admin/src/features/tech/tags/tech_tag_list_screen.dart';
import 'package:portfolio_admin/src/features/tech/tech_article.dart';
import 'package:portfolio_admin/src/features/tech/tech_tag.dart';
import 'package:portfolio_admin/src/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechArticleEditScreen extends StatefulWidget {
  final String id;

  const TechArticleEditScreen({Key? key, required this.id}) : super(key: key);

  @override
  _TechArticleEditScreenState createState() => _TechArticleEditScreenState();
}

class TechArticleEditScreenArguments {
  final String id;

  TechArticleEditScreenArguments(this.id);
}

class _TechArticleEditScreenState
    extends AuthRequiredState<TechArticleEditScreen> {
  late TechArticle article;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  DateTime? _publishedAt;
  var _isLoading = false;
  var _isUpdating = false;

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getArticle() async {
    setState(() => _isLoading = true);

    final articleResponse = await supabase
        .from('tech_articles')
        .select(
            'id, published_at, title, content, eyecatches ( url, width, height ), tech_article_tag_links ( tech_tag_id, tech_tags ( name ) )')
        .eq('id', widget.id)
        .single()
        .execute();

    if (!mounted) return;
    final articlesError = articleResponse.error;
    if (articlesError != null && articleResponse.status != 406) {
      context.showErrorSnackBar(message: articlesError.message);
    }

    final entity = articleResponse.data;
    article = TechArticle(
      (entity['id'] ?? '') as String,
      entity['published_at'] is String
          ? entity['published_at'] as String
          : null,
      (entity['title'] ?? '') as String,
      (entity['content'] ?? '') as String,
      (entity['eyecatches'] != null)
          ? Eyecatch(
              entity['eyecatches']['url'] as String,
              entity['eyecatches']['width'] as int,
              entity['eyecatches']['height'] as int,
            )
          : null,
      (entity['tech_article_tag_links'] != null)
          ? (entity['tech_article_tag_links'] as List<dynamic>)
              .map<TechTag>(
                (dynamic tagEntity) => TechTag(
                  tagEntity['tech_tag_id'] as String,
                  tagEntity['tech_tags']['name'] as String,
                ),
              )
              .toList()
          : List.empty(),
    );

    _titleController.text = article.title;
    _contentController.text = article.content;

    final publishedAtString = article.publishedAt;
    setState(() => _publishedAt = (publishedAtString != null)
        ? DateTime.tryParse(publishedAtString)
        : null);

    setState(() => _isLoading = false);
  }

  Future<void> _updateArticle() async {
    setState(() => _isUpdating = true);

    setState(() => _isUpdating = false);
  }

  @override
  void onAuthenticated(Session session) {
    final user = session.user;
    if (user != null) {
      _getArticle();
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy/MM/dd(E) HH:mm', 'ja');

    return Scaffold(
      appBar: AppBar(
        title: const Text('技術ブログ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tag),
            onPressed: () {
              Navigator.restorablePushNamed(
                context,
                TechTagListScreen.routeName,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    '公開日時:',
                    // style: TextStyle(
                    //   fontWeight: FontWeight.bold,
                    // ),
                  ),
                  const SizedBox(width: 8),
                  Text((_publishedAt != null)
                      ? formatter.format(_publishedAt!)
                      : '未設定'),
                  ClipOval(
                    child: Material(
                      child: InkWell(
                        onTap: () => DatePicker.showDateTimePicker(
                          context,
                          showTitleActions: true,
                          onConfirm: (DateTime date) {
                            setState(() => _publishedAt = date);
                          },
                          currentTime: _publishedAt,
                          locale: LocaleType.jp,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: const Icon(Icons.edit),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Text('タイトル'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 32),
              const Text('内容'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                minLines: 24,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isUpdating ? null : _updateArticle,
                child: Text(_isUpdating ? '保存中です...' : '保存する'),
              ),
              const SizedBox(height: 32),
            ],
          ),
          AnimatedOpacity(
            opacity: _isLoading ? 1: 0,
            duration: const Duration(milliseconds: 250),
            child: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
        ],
      ),
    );
  }
}
