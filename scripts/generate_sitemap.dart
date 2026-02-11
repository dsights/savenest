import 'dart:io';
import 'dart:convert';

void main() async {
  print('Generating sitemap.xml...');

  final productsFile = File('assets/data/products.json');
  final blogFile = File('assets/data/blog_posts.json');
  final sitemapFile = File('web/sitemap.xml');

  if (!productsFile.existsSync() || !blogFile.existsSync()) {
    print('Error: Data files not found.');
    return;
  }

  final productsJson = jsonDecode(await productsFile.readAsString());
  final blogJson = jsonDecode(await blogFile.readAsString()) as List;

  final buffer = StringBuffer();
  buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  buffer.writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">');

  // Static Pages
  final staticRoutes = [
    '/',
    '/savings',
    '/deals/electricity',
    '/deals/gas',
    '/deals/internet',
    '/deals/mobile',
    '/deals/insurance',
    '/deals/credit-cards',
    '/blog',
    '/about',
    '/contact',
    '/privacy',
    '/terms',
    '/how-it-works',
  ];

  for (var route in staticRoutes) {
    buffer.writeln('  <url>');
    buffer.writeln('    <loc>https://savenest.au$route</loc>');
    buffer.writeln('    <changefreq>weekly</changefreq>');
    buffer.writeln('    <priority>0.8</priority>');
    buffer.writeln('  </url>');
  }

  // Product Pages
  // Assuming productsJson is Map<String, List>
  productsJson.forEach((category, list) {
    if (list is List) {
      for (var item in list) {
        if (item is Map && item.containsKey('id')) {
          buffer.writeln('  <url>');
          buffer.writeln('    <loc>https://savenest.au/deal/${item['id']}</loc>');
          buffer.writeln('    <changefreq>monthly</changefreq>');
          buffer.writeln('    <priority>0.7</priority>');
          buffer.writeln('  </url>');
        }
      }
    }
  });

  // Blog Pages
  for (var post in blogJson) {
    if (post is Map && post.containsKey('slug')) {
      buffer.writeln('  <url>');
      buffer.writeln('    <loc>https://savenest.au/blog/${post['slug']}</loc>');
      buffer.writeln('    <changefreq>monthly</changefreq>');
      buffer.writeln('    <priority>0.6</priority>');
      buffer.writeln('  </url>');
    }
  }

  // State Guides
  final states = ['nsw', 'vic', 'qld', 'sa', 'wa', 'act', 'tas'];
  final utilities = ['electricity', 'gas', 'internet'];

  for (var state in states) {
    for (var utility in utilities) {
      buffer.writeln('  <url>');
      buffer.writeln('    <loc>https://savenest.au/guides/$state/$utility</loc>');
      buffer.writeln('    <changefreq>monthly</changefreq>');
      buffer.writeln('    <priority>0.7</priority>');
      buffer.writeln('  </url>');
    }
  }

  buffer.writeln('</urlset>');

  await sitemapFile.writeAsString(buffer.toString());
  print('Sitemap generated with ${buffer.toString().split('\n').length} lines.');
}
