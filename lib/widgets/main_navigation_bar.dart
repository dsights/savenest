import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainNavigationBar extends StatefulWidget {
  const MainNavigationBar({super.key});

  @override
  State<MainNavigationBar> createState() => _MainNavigationBarState();
}

class _MainNavigationBarState extends State<MainNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1100;

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              InkWell(
                onTap: () => context.go('/'),
                child: Row(
                  children: [
                    const Icon(Icons.shield_moon, color: AppTheme.accentOrange, size: 32),
                    const SizedBox(width: 10),
                    Text(
                      'SaveNest',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.deepNavy,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ],
                ),
              ),

              // Desktop Navigation with Icons
              if (isDesktop)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _serviceNavItem(context, "Electricity", Icons.bolt, '/deals/electricity'),
                      _serviceNavItem(context, "Gas", Icons.local_fire_department, '/deals/gas'),
                      _serviceNavItem(context, "Internet", Icons.wifi, '/deals/internet'),
                      _serviceNavItem(context, "Mobile", Icons.phone_iphone, '/deals/mobile'),
                      _serviceNavItem(context, "Health", Icons.medical_services, '/deals/insurance/health'),
                      _serviceNavItem(context, "Car", Icons.directions_car, '/deals/insurance/car'),
                      _serviceNavItem(context, "Finance", Icons.credit_card, '/deals/credit-cards'),
                    ],
                  ),
                ),

              // Action Buttons
              if (MediaQuery.of(context).size.width > 800)
                Row(
                  children: [
                    _navLink(context, 'Blog', '/blog'),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/savings'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        backgroundColor: AppTheme.primaryBlue,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calculate_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Calculator', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                )
              else
                IconButton(
                  icon: const Icon(Icons.menu, color: AppTheme.deepNavy, size: 28),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _serviceNavItem(BuildContext context, String title, IconData icon, String route) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isSelected = currentPath == route;

    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.slate600,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primaryBlue : AppTheme.slate600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navLink(BuildContext context, String title, String route) {
    return InkWell(
      onTap: () => context.go(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: const TextStyle(
            color: AppTheme.deepNavy,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}