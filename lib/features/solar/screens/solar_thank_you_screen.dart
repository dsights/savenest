import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/main_navigation_bar.dart';
import '../../../widgets/main_mobile_drawer.dart';

class SolarThankYouScreen extends StatelessWidget {
  const SolarThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const MainMobileDrawer(),
      body: Column(
        children: [
          const MainNavigationBar(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppTheme.vibrantEmerald, size: 100),
                      const SizedBox(height: 32),
                      const Text(
                        "We've Received Your Request!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Check your inbox. We've sent you a quick question about your roof type to help us finalize your savings calculation.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: AppTheme.slate600),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "One of our local solar experts will be in touch shortly from a business number.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: AppTheme.slate600, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: () => context.go('/'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        ),
                        child: const Text("BACK TO HOMEPAGE"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
