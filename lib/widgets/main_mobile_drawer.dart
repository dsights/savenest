import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'savenest_logo.dart';

class MainMobileDrawer extends StatelessWidget {
  const MainMobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.offWhite,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: SaveNestLogo(fontSize: 24),
          ),
          
          _drawerItem(context, 'Electricity Deals', '/deals/electricity', Icons.bolt),
          _drawerItem(context, 'Gas Plans', '/deals/gas', Icons.local_fire_department),
          _drawerItem(context, 'Internet (NBN)', '/deals/internet', Icons.wifi),
          _drawerItem(context, 'Mobile Plans', '/deals/mobile', Icons.phone_iphone),
          
          const Divider(height: 32),
          
          _drawerItem(context, 'Health Insurance', '/deals/insurance/health', Icons.medical_services),
          _drawerItem(context, 'Car Insurance', '/deals/insurance/car', Icons.directions_car),
          _drawerItem(context, 'Credit Cards', '/deals/credit-cards', Icons.credit_card),
          
          const Divider(height: 32),

          _drawerItem(context, 'Blog & Insights', '/blog', Icons.article_outlined),
          _drawerItem(context, 'Contact Us', '/contact', Icons.contact_support_outlined),
          _drawerItem(context, 'How it Works', '/how-it-works', Icons.help_outline),
          
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/savings');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calculate_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('SAVINGS CALCULATOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, String title, String route, IconData icon) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isSelected = currentPath == route;

    return ListTile(
      leading: Icon(
        icon, 
        color: isSelected ? AppTheme.accentOrange : AppTheme.deepNavy.withOpacity(0.7),
        size: 22,
      ),
      title: Text(
        title, 
        style: TextStyle(
          color: isSelected ? AppTheme.accentOrange : AppTheme.deepNavy,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
