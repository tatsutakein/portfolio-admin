import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:portfolio_admin/src/components/auth_required_state.dart';
import 'package:portfolio_admin/src/features/tech/articles/tech_article_edit_screen.dart';
import 'package:portfolio_admin/src/features/tech/articles/tech_articles.dart';
import 'package:portfolio_admin/src/features/eyecatches/eyecatch.dart';
import 'package:portfolio_admin/src/features/tech/tags/tech_tag_list_screen.dart';
import 'package:portfolio_admin/src/features/tech/tech_article.dart';
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
  var _isLoading = false;

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getArticles() async {
    setState(() => _isLoading = true);

    final articlesResponse = await supabase
        .from('tech_articles')
        .select(
            'id, published_at, title, content, eyecatches ( id, url, width, height )')
        .order('created_at', ascending: false)
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
        articleEntity['eyecatches'] != null
            ? Eyecatch(
                articleEntity['eyecatches']['id'] as String,
                articleEntity['eyecatches']['url'] as String,
                articleEntity['eyecatches']['width'] as int,
                articleEntity['eyecatches']['height'] as int,
              )
            : null,
      );
    }).toList();

    setState(() => _isLoading = false);
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
    final formatter = DateFormat('yyyy/MM/dd(E) HH:mm', 'ja');

    return Scaffold(
        appBar: AppBar(
          title: const Text('技術ブログ'),
          actions: [
            IconButton(
              icon: const Icon(Icons.tag),
              tooltip: 'タグ管理',
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
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // noop
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('New Article'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return const Divider(
                          height: 0.5,
                        );
                      },
                      restorationId: 'techArticleListView',
                      itemCount: articles.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = articles[index];
                        final publishedAtString = item.publishedAt;
                        final publishedAt = (publishedAtString != null)
                            ? DateTime.tryParse(publishedAtString)
                            : null;

                        final publishState = (publishedAt != null)
                            ? "公開日時: ${formatter.format(publishedAt)}"
                            : '下書き';

                        return ListTile(
                          title: Text(item.title),
                          subtitle: Text(publishState),
                          leading: CircleAvatar(
                            foregroundImage:
                                NetworkImage(item.eyecatch?.url ?? ''),
                          ),
                          contentPadding: const EdgeInsets.all(8),
                          onTap: () {
                            // Navigate to the details page. If the user leaves and returns to
                            // the app after it has been killed while running in the
                            // background, the navigation stack is restored.
                            Navigator.pushNamed(
                              context,
                              TechArticlesScreen.routeName,
                              arguments:
                                  TechArticleEditScreenArguments(item.id),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: _isLoading ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          ],
        ));
  }
}
