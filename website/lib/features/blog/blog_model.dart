class BlogPost {
  final String id;
  final String slug;
  final String title;
  final String category;
  final String author;
  final String date;
  final String imageUrl;
  final String thumbnailUrl;
  final String summary;
  final String content;

  BlogPost({
    required this.id,
    required this.slug,
    required this.title,
    required this.category,
    required this.author,
    required this.date,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.summary,
    required this.content,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'],
      slug: json['slug'] ?? json['id'], // Fallback to ID if slug missing temporarily
      title: json['title'],
      category: json['category'],
      author: json['author'],
      date: json['date'],
      imageUrl: json['imageUrl'],
      thumbnailUrl: json['thumbnailUrl'] ?? json['imageUrl'],
      summary: json['summary'],
      content: json['content'],
    );
  }
}
