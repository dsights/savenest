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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
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

    return _HoverableServiceItem(
      title: title,
      icon: icon,
      route: route,
      isSelected: isSelected,
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

class _HoverableServiceItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final String route;
  final bool isSelected;

  const _HoverableServiceItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.isSelected,
  });

  @override
  State<_HoverableServiceItem> createState() => _HoverableServiceItemState();
}

class _HoverableServiceItemState extends State<_HoverableServiceItem> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isSelected ? AppTheme.primaryBlue : (_isHovered ? AppTheme.accentOrange : AppTheme.slate600);

    return InkWell(
      onTap: () => context.go(widget.route),
      onHover: (hover) => setState(() => _isHovered = hover),
      child: AnimatedScale(
        scale: _isHovered ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppTheme.primaryBlue.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.isSelected || _isHovered)
                    FadeTransition(
                      opacity: _pulseController,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeColor.withOpacity(0.2),
                        ),
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: activeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 22,
                      color: activeColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: (widget.isSelected || _isHovered) ? FontWeight.bold : FontWeight.w500,
                  color: activeColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
