import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class PageHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badge;

  const PageHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.primaryBlue,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (badge != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    badge!.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      fontSize: 14,
                    ),
                  ),
                ),
              Text(
                title,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width > 600 ? 48 : 36,
                    ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        height: 1.6,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
