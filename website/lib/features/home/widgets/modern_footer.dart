import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../widgets/savenest_logo.dart';
import '../../../theme/app_theme.dart';

class ModernFooter extends StatelessWidget {
  const ModernFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    
    return Container(
      color: AppTheme.deepNavy, // Dark contrast
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Main Footer Content
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo & About
                  Expanded(
                    flex: isMobile ? 0 : 2,
                    child: Column(
                      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      children: [
                        const SaveNestLogo(fontSize: 28, isLight: true),
                        const SizedBox(height: 24),
                        Text(
                          "Empowering Australians to make smarter financial choices by comparing utilities, insurance, and more.",
                          textAlign: isMobile ? TextAlign.center : TextAlign.start,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            height: 1.6,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
                          children: [
                            _socialIcon(Icons.facebook),
                            const SizedBox(width: 16),
                            _socialIcon(Icons.camera_alt),
                            const SizedBox(width: 16),
                            _socialIcon(Icons.business),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  if (!isMobile) const SizedBox(width: 80),
                  if (isMobile) const SizedBox(height: 60),

                  // Quick Links
                  Expanded(
                    child: _footerColumn(context, "Services", [
                      _footerLink(context, 'Electricity', '/deals/electricity'),
                      _footerLink(context, 'Gas', '/deals/gas'),
                      _footerLink(context, 'Internet', '/deals/internet'),
                      _footerLink(context, 'Mobile', '/deals/mobile'),
                      _footerLink(context, 'Provider Directory', '/providers'),
                      _footerLink(context, 'Moving House', '/energy/moving-house'),
                    ]),
                  ),
                  
                  Expanded(
                    child: _footerColumn(context, "Insurance", [
                      _footerLink(context, 'Health Insurance', '/deals/insurance/health'),
                      _footerLink(context, 'Car Insurance', '/deals/insurance/car'),
                      _footerLink(context, 'Home Insurance', '/deals/insurance/home'),
                    ]),
                  ),

                  Expanded(
                    child: _footerColumn(context, "State Guides", [
                      _footerLink(context, 'NSW Energy Guide', '/guides/nsw/electricity'),
                      _footerLink(context, 'VIC Energy Guide', '/guides/vic/electricity'),
                      _footerLink(context, 'QLD Energy Guide', '/guides/qld/electricity'),
                      _footerLink(context, 'SA Energy Guide', '/guides/sa/electricity'),
                    ]),
                  ),

                  Expanded(
                    child: _footerColumn(context, "Company", [
                      _footerLink(context, 'About Us', '/about'),
                      _footerLink(context, 'Contact Us', '/contact'),
                      _footerLink(context, 'Blog', '/blog'),
                      _footerLink(context, 'For Partners', '/partners/advertise'),
                    ]),
                  ),
                ],
              ),
              
              const SizedBox(height: 80),
              const Divider(color: Colors.white12),
              const SizedBox(height: 40),
              
              // Bottom Footer
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 24,
                runSpacing: 20,
                children: [
                  Text(
                    '© 2026 SaveNest | ABN 89691841059 | Pratham Technologies Pty Ltd',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                  ),
                  Wrap(
                    spacing: 24,
                    children: [
                      _footerLink(context, 'Privacy Policy', '/privacy', isSmall: true),
                      _footerLink(context, 'Terms of Service', '/terms', isSmall: true),
                      _footerLink(context, 'Disclaimer', '/legal/disclaimer', isSmall: true),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _footerColumn(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        ...items,
      ],
    );
  }

  Widget _footerLink(BuildContext context, String text, String route, {bool isSmall = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go(route),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(isSmall ? 0.4 : 0.6),
            fontSize: isSmall ? 12 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
