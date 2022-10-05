import 'package:flutter/material.dart';
import 'package:portfolio_admin/src/components/auth_required_state.dart';
import 'package:portfolio_admin/src/features/auth/change_password_screen.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('技術ブログ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tag),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.

              Navigator.restorablePushNamed(
                context,
                TechTagListScreen.routeName,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'タイトル',
              icon: Icon(Icons.title),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: '内容',
              icon: Icon(Icons.text_fields_outlined),
              border: OutlineInputBorder(),
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isUpdating ? null : _updateArticle,
            child: Text(_isUpdating ? 'Updating' : 'Update'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
