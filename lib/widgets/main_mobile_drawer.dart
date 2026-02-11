import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainMobileDrawer extends StatelessWidget {
  const MainMobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.deepNavy,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        children: [
          Row(
            children: [
              const Icon(Icons.shield_moon, color: AppTheme.vibrantEmerald, size: 28),
              const SizedBox(width: 8),
              Text(
                'SaveNest',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _drawerItem(context, 'Electricity', '/deals/electricity'),
          _drawerItem(context, 'Gas', '/deals/gas'),
          _drawerItem(context, 'Internet', '/deals/internet'),
          _drawerItem(context, 'Mobile', '/deals/mobile'),
          _drawerItem(context, 'Blog', '/blog'),
          _drawerItem(context, 'Contact Us', '/contact'),
          _drawerItem(context, 'Savings Calculator', '/savings'),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
      onTap: () {
        Navigator.pop(context);
        GoRouter.of(context).go(route);
      },
    );
  }
}
