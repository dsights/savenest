import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainNavigationBar extends StatelessWidget {
  const MainNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: AppTheme.deepNavy,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => context.go('/'),
                child: Row(
                  children: [
                    const Icon(Icons.shield_moon, color: AppTheme.vibrantEmerald, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'SaveNest',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                    ),
                  ],
                ),
              ),
              if (MediaQuery.of(context).size.width > 900) // Adjusted breakpoint for better fit
                Row(
                  children: [
                    _navLink(context, 'Electricity', '/deals/electricity'),
                    _navLink(context, 'Gas', '/deals/gas'),
                    _navLink(context, 'Internet', '/deals/internet'),
                    _navLink(context, 'Mobile', '/deals/mobile'),
                    _navLink(context, 'Blog', '/blog'), // Added Blog link
                    _navLink(context, 'Contact', '/contact'),
                    _navLink(context, 'Savings Calculator', '/savings'),
                  ],
                )
              else
                // Mobile Menu Button
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navLink(BuildContext context, String title, String route) {
    return InkWell(
      onTap: () => GoRouter.of(context).go(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
