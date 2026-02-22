import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String referralCode = "SAVE2026";

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainBackgroundGradient,
        ),
        child: Column(
          children: [
            const MainNavigationBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: AppTheme.vibrantEmerald.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.card_giftcard_rounded,
                            size: 80,
                            color: AppTheme.vibrantEmerald,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Invite Friends, Earn Cash',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepNavy,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Share your unique link. When they switch, you both get \$50 credited to your account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.deepNavy.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          borderRadius: 24,
                          child: Column(
                            children: [
                              const Text(
                                'YOUR REFERRAL CODE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: AppTheme.slate600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                decoration: BoxDecoration(
                                  color: AppTheme.offWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.slate300, style: BorderStyle.solid),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      referralCode,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.deepNavy,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy_rounded, color: AppTheme.accentOrange),
                                      onPressed: () {
                                        Clipboard.setData(const ClipboardData(text: referralCode));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Code copied to clipboard!')),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                     // TODO: Implement share
                                     ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Sharing functionality coming soon!')),
                                     );
                                  },
                                  icon: const Icon(Icons.share_rounded),
                                  label: const Text('Share Link'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextButton(
                           onPressed: () => context.pop(),
                           child: const Text('Back to Savings'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
