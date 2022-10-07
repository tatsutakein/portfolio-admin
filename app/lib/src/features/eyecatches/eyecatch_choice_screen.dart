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

class EyecatchChoiceScreen extends StatefulWidget {
  const EyecatchChoiceScreen({Key? key}) : super(key: key);

  static const routeName = '/eyecatches/choice';

  @override
  EyecatchChoiceScreenState createState() => EyecatchChoiceScreenState();
}

class EyecatchChoiceScreenState
    extends AuthRequiredState<EyecatchChoiceScreen> {
  List<Eyecatch> eyecatches = [];
  var _isLoading = false;

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getArticles() async {
    setState(() => _isLoading = true);

    final response = await supabase
        .from('eyecatches')
        .select('id, url, width, height')
        .execute();

    if (!mounted) return;
    final error = response.error;
    if (error != null && response.status != 406) {
      context.showErrorSnackBar(message: error.message);
    }

    setState(() {
      eyecatches =
          (response.data as List<dynamic>).map<Eyecatch>((dynamic entity) {
        return Eyecatch(
          entity['id'] as String,
          entity['url'] as String,
          entity['width'] as int,
          entity['height'] as int,
        );
      }).toList();
    });

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
    return Scaffold(
        appBar: AppBar(
          title: const Text('アイキャッチ'),
        ),
        body: Stack(
          children: [
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: eyecatches.length,
              itemBuilder: (BuildContext context, int index) {
                final item = eyecatches[index];

                return InkWell(
                  onTap: () {
                    Navigator.pop(context, item);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Image.network(item.url),
                  ),
                );
              },
            ),
            AnimatedOpacity(
              opacity: _isLoading ? 1 : 0,
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
