import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainMobileDrawer extends StatelessWidget {
  const MainMobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.offWhite,
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
                      color: AppTheme.deepNavy,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          ExpansionTile(
            title: const Text('Services', style: TextStyle(color: AppTheme.deepNavy, fontSize: 18)),
            iconColor: AppTheme.vibrantEmerald,
            collapsedIconColor: AppTheme.deepNavy,
            children: [
              _drawerSubItem(context, 'Electricity', Icons.bolt, '/deals/electricity'),
              _drawerSubItem(context, 'Gas', Icons.local_fire_department, '/deals/gas'),
              _drawerSubItem(context, 'Internet', Icons.wifi, '/deals/internet'),
              _drawerSubItem(context, 'Mobile', Icons.phone_iphone, '/deals/mobile'),
              _drawerSubItem(context, 'Health Insurance', Icons.medical_services, '/deals/insurance/health'),
              _drawerSubItem(context, 'Car Insurance', Icons.directions_car, '/deals/insurance/car'),
              _drawerSubItem(context, 'Credit Cards', Icons.credit_card, '/deals/credit-cards'),
              _drawerSubItem(context, 'Home Loans', Icons.home_work, '/loans/home'),
            ],
          ),

          _drawerItem(context, 'Deals', '/deals/electricity'),
          _drawerItem(context, 'Blog', '/blog'),
          _drawerItem(context, 'Contact Us', '/contact'),
          
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                GoRouter.of(context).go('/savings');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vibrantEmerald,
                foregroundColor: AppTheme.deepNavy,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calculate_outlined),
                  SizedBox(width: 8),
                  Text('Savings Calculator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerSubItem(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.deepNavy.withOpacity(0.7), size: 20),
      title: Text(title, style: TextStyle(color: AppTheme.deepNavy.withOpacity(0.7), fontSize: 16)),
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      onTap: () {
        Navigator.pop(context);
        GoRouter.of(context).go(route);
      },
    );
  }

  Widget _drawerItem(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: AppTheme.deepNavy, fontSize: 18)),
      onTap: () {
        Navigator.pop(context);
        GoRouter.of(context).go(route);
      },
    );
  }
}
