import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainNavigationBar extends StatelessWidget {
  const MainNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: Colors.white,
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
                            color: AppTheme.deepNavy,
                            letterSpacing: 1.0,
                          ),
                    ),
                  ],
                ),
              ),
              if (MediaQuery.of(context).size.width > 900) // Adjusted breakpoint for better fit
                Row(
                  children: [
                    // Services Mega Menu (Dropdown)
                    Theme(
                      data: Theme.of(context).copyWith(
                        popupMenuTheme: PopupMenuThemeData(
                          color: Colors.white,
                          surfaceTintColor: Colors.white,
                          textStyle: const TextStyle(color: AppTheme.deepNavy),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.black12),
                          ),
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        offset: const Offset(0, 40),
                        tooltip: 'Show Services',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              const Text(
                                'Services',
                                style: TextStyle(
                                  color: AppTheme.deepNavy,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down, color: AppTheme.deepNavy.withOpacity(0.7), size: 16),
                            ],
                          ),
                        ),
                        onSelected: (route) => context.go(route),
                        itemBuilder: (context) => [
                          _serviceMenuItem('Electricity', Icons.bolt, '/deals/electricity'),
                          _serviceMenuItem('Gas', Icons.local_fire_department, '/deals/gas'),
                          _serviceMenuItem('Internet', Icons.wifi, '/deals/internet'),
                          _serviceMenuItem('Mobile', Icons.phone_iphone, '/deals/mobile'),
                          const PopupMenuDivider(),
                          _serviceMenuItem('Health Insurance', Icons.medical_services, '/deals/insurance/health'),
                          _serviceMenuItem('Car Insurance', Icons.directions_car, '/deals/insurance/car'),
                          const PopupMenuDivider(),
                          _serviceMenuItem('Credit Cards', Icons.credit_card, '/deals/credit-cards'),
                          _serviceMenuItem('Home Loans', Icons.home_work, '/loans/home'),
                        ],
                      ),
                    ),

                    // Deals Link
                    _navLink(context, 'Deals', '/deals/electricity'), // Defaulting to electricity for now as main deals hub

                    _navLink(context, 'Blog', '/blog'),
                    _navLink(context, 'Contact', '/contact'),
                    
                    const SizedBox(width: 16),
                    
                    // Savings Calculator Button
                    ElevatedButton(
                      onPressed: () => context.go('/savings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.vibrantEmerald,
                        foregroundColor: AppTheme.deepNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        elevation: 4,
                        shadowColor: AppTheme.vibrantEmerald.withOpacity(0.4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calculate_outlined, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Savings Calculator',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                // Mobile Menu Button
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: AppTheme.deepNavy),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _serviceMenuItem(String title, IconData icon, String route) {
    return PopupMenuItem<String>(
      value: route,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.vibrantEmerald, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(color: AppTheme.deepNavy, fontSize: 14),
          ),
        ],
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
          style: TextStyle(
            color: AppTheme.deepNavy.withOpacity(0.7),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
