import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_navigation_bar.dart';
import '../home/widgets/modern_footer.dart';

class ConciergeScreen extends StatefulWidget {
  const ConciergeScreen({super.key});

  @override
  State<ConciergeScreen> createState() => _ConciergeScreenState();
}

class _ConciergeScreenState extends State<ConciergeScreen> {
  int _currentStep = 0;
  bool _isSwitching = false;

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      setState(() => _isSwitching = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() { _isSwitching = false; _currentStep = 4; });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: Column(
        children: [
          const MainNavigationBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      const Icon(Icons.support_agent, size: 64, color: AppTheme.primaryBlue),
                      const SizedBox(height: 16),
                      const Text(
                        'SaveNest Concierge',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.deepNavy),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'We handle the entire switching process for you. Zero stress, maximum savings.',
                        style: TextStyle(fontSize: 16, color: AppTheme.slate600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                        ),
                        child: _buildWizard(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const ModernFooter(),
        ],
      ),
    );
  }

  Widget _buildWizard() {
    if (_currentStep == 4) {
      return Column(
        children: [
          const Icon(Icons.check_circle, size: 80, color: AppTheme.vibrantEmerald),
          const SizedBox(height: 24),
          const Text('Switch Initiated!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.deepNavy)),
          const SizedBox(height: 16),
          const Text('Your new provider will contact you shortly. We have securely transferred your details.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppTheme.slate600)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            child: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      );
    }

    if (_isSwitching) {
      return const Column(
        children: [
          CircularProgressIndicator(color: AppTheme.accentOrange),
          SizedBox(height: 24),
          Text('Negotiating with providers and securely transferring your profile...', style: TextStyle(fontSize: 16, color: AppTheme.slate600)),
        ],
      );
    }

    return Stepper(
      currentStep: _currentStep,
      onStepContinue: _nextStep,
      onStepCancel: () { if (_currentStep > 0) setState(() => _currentStep--); },
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: details.onStepContinue,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.vibrantEmerald, foregroundColor: AppTheme.deepNavy),
                child: Text(_currentStep == 3 ? 'Confirm 1-Click Switch' : 'Next Step', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (_currentStep > 0) ...[
                const SizedBox(width: 16),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back', style: TextStyle(color: AppTheme.slate600)),
                )
              ]
            ],
          ),
        );
      },
      steps: [
        Step(
          title: const Text('Confirm Identity', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('We use secure Open Banking (CDR) to verify your identity without uploading physical documents.'),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text('Authorize SaveNest', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Provide authorization for us to act on your behalf to cancel your old plan and set up the new one.'),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: const Text('Smart Meter Sync', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Connecting to your smart meter to ensure the new tariff perfectly matches your exact usage profile.'),
          isActive: _currentStep >= 2,
        ),
        Step(
          title: const Text('Final Review', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('You are switching to AGL Smart Saver. Estimated annual savings: \$450. No exit fees from your current provider detected.'),
          isActive: _currentStep >= 3,
        ),
      ],
    );
  }
}
