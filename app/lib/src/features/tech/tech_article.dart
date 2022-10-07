import 'package:portfolio_admin/src/features/eyecatches/eyecatch.dart';
import 'package:portfolio_admin/src/features/tech/tech_tag.dart';

/// 技術記事
class TechArticle {
  final String id;
  final String? publishedAt;
  final String title;
  final String content;
  final Eyecatch? eyecatch;
  final List<TechTag> tags;

  const TechArticle(this.id, this.publishedAt, this.title, this.content,
      this.eyecatch, this.tags);
}

/// 一覧表示用の技術記事
class SimpleTechArticle {
  final String id;
  final String? publishedAt;
  final String title;
  final Eyecatch? eyecatch;

  const SimpleTechArticle(this.id, this.publishedAt, this.title, this.eyecatch);
}
