import 'package:flutter/material.dart';
import 'package:portfolio_admin/src/components/auth_required_state.dart';
import 'package:portfolio_admin/src/features/auth/change_password_screen.dart';
import 'package:portfolio_admin/src/features/tech/articles/tech_article_edit_screen.dart';
import 'package:portfolio_admin/src/features/tech/articles/tech_articles.dart';
import 'package:portfolio_admin/src/features/tech/eyecatch.dart';
import 'package:portfolio_admin/src/features/tech/tags/tech_tag_list_screen.dart';
import 'package:portfolio_admin/src/features/tech/tech_article.dart';
import 'package:portfolio_admin/src/features/tech/tech_tag.dart';
import 'package:portfolio_admin/src/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechArticleListScreen extends StatefulWidget {
  const TechArticleListScreen({Key? key}) : super(key: key);

  @override
  _TechArticleListScreenState createState() => _TechArticleListScreenState();
}

class _TechArticleListScreenState
    extends AuthRequiredState<TechArticleListScreen> {
  List<SimpleTechArticle> articles = [];
  var _loading = false;

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getArticles() async {
    setState(() {
      _loading = true;
    });
    final articlesResponse = await supabase
        .from('tech_full_articles')
        .select('id, published_at, title, content, url, width, height')
        .execute();

    if (!mounted) return;
    final articlesError = articlesResponse.error;
    if (articlesError != null && articlesResponse.status != 406) {
      context.showErrorSnackBar(message: articlesError.message);
    }
    final articleEntities = articlesResponse.data as List<dynamic>;

    articles = articleEntities.map<SimpleTechArticle>((dynamic articleEntity) {
      return SimpleTechArticle(
        (articleEntity['id'] ?? '') as String,
        articleEntity['published_at'] is String
            ? articleEntity['published_at'] as String
            : null,
        (articleEntity['title'] ?? '') as String,
        (articleEntity['url'] != null)
            ? Eyecatch(articleEntity['url'] as String,
                articleEntity['width'] as int, articleEntity['height'] as int)
            : null,
      );
    }).toList();

    setState(() {
      _loading = false;
    });
  }

  @override
  void onAuthenticated(Session session) {
    final user = session.user;
    if (user != null) {
      _getArticles();
    }
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
      body: ListView.builder(

        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        restorationId: 'techArticleListView',
        itemCount: articles.length,
        itemBuilder: (BuildContext context, int index) {
          final item = articles[index];
          final publishState = item.publishedAt ?? '下書き';

          return Card(
            child: ListTile(
              title: Text("$publishState: ${item.title}"),
              leading: CircleAvatar(
                foregroundImage: NetworkImage(item.eyecatch?.url ?? ''),
              ),
              onTap: () {
                // Navigate to the details page. If the user leaves and returns to
                // the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.pushNamed(
                  context,
                  TechArticlesScreen.routeName,
                  arguments: TechArticleEditScreenArguments(item.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
