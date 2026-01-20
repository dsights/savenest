import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'blog_model.dart';

class BlogPostScreen extends StatelessWidget {
  final BlogPost post;

  const BlogPostScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  post.imageUrl.startsWith('assets/')
                      ? Image.asset(
                          post.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          post.imageUrl,
                          fit: BoxFit.cover,
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.deepNavy.withOpacity(0.9),
                          AppTheme.deepNavy,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metadata
                      Row(
                        children: [
                          Text(
                            post.category.toUpperCase(),
                            style: const TextStyle(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            post.date,
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        post.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Body
                      Text(
                        post.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.6,
                        ),
                      ),
                      
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
