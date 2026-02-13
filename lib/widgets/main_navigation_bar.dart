import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainNavigationBar extends StatefulWidget {
  const MainNavigationBar({super.key});

  @override
  State<MainNavigationBar> createState() => _MainNavigationBarState();
}

class _MainNavigationBarState extends State<MainNavigationBar> {
  bool _isServicesOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleOverlay() {
    if (_isServicesOpen) {
      _closeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
    setState(() => _isServicesOpen = true);
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isServicesOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        top: renderBox.localToGlobal(Offset.zero).dy + size.height,
        left: 0,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(-renderBox.localToGlobal(Offset.zero).dx, size.height),
          child: MouseRegion(
            onExit: (_) => _closeOverlay(),
            child: Material(
              elevation: 20,
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Compare & Save Today",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepNavy,
                              ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildMegaMenuColumn(
                                "Utilities",
                                [
                                  _megaMenuItem("Electricity", Icons.bolt, '/deals/electricity'),
                                  _megaMenuItem("Gas", Icons.local_fire_department, '/deals/gas'),
                                  _megaMenuItem("Internet", Icons.wifi, '/deals/internet'),
                                  _megaMenuItem("Mobile", Icons.phone_iphone, '/deals/mobile'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: _buildMegaMenuColumn(
                                "Insurance",
                                [
                                  _megaMenuItem("Health Insurance", Icons.medical_services, '/deals/insurance/health'),
                                  _megaMenuItem("Car Insurance", Icons.directions_car, '/deals/insurance/car'),
                                  _megaMenuItem("Home Insurance", Icons.home, '/deals/insurance/home'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: _buildMegaMenuColumn(
                                "Finance",
                                [
                                  _megaMenuItem("Credit Cards", Icons.credit_card, '/deals/credit-cards'),
                                  _megaMenuItem("Home Loans", Icons.home_work, '/loans/home'),
                                  _megaMenuItem("Personal Loans", Icons.monetization_on, '/loans/personal'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMegaMenuColumn(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _megaMenuItem(String title, IconData icon, String route) {
    return InkWell(
      onTap: () {
        _closeOverlay();
        context.go(route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accentOrange, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.deepNavy,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
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
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                if (MediaQuery.of(context).size.width > 1000)
                  Row(
                    children: [
                      MouseRegion(
                        onEnter: (_) => _showOverlay(),
                        child: InkWell(
                          onTap: _toggleOverlay,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Text(
                                  'Services',
                                  style: TextStyle(
                                    color: _isServicesOpen ? AppTheme.accentOrange : AppTheme.deepNavy,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _isServicesOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: _isServicesOpen ? AppTheme.accentOrange : AppTheme.deepNavy,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _navLink(context, 'Deals', '/deals/electricity'),
                      _navLink(context, 'Blog', '/blog'),
                      _navLink(context, 'Contact', '/contact'),
                      const SizedBox(width: 24),
                      ElevatedButton(
                        onPressed: () => context.go('/savings'),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calculate_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Savings Calculator'),
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
