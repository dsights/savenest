import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../services/hubspot_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_navigation_bar.dart';
import '../home/widgets/modern_footer.dart';
import 'comparison_model.dart';

class ConciergeScreen extends StatefulWidget {
  final Deal? deal;

  const ConciergeScreen({super.key, this.deal});

  @override
  State<ConciergeScreen> createState() => _ConciergeScreenState();
}

class _ConciergeScreenState extends State<ConciergeScreen> {
  int _currentStep = 0;
  bool _isSwitching = false;
  bool _hasAgreed = false;
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hubSpotService = HubSpotService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<Uint8List> _generateAgreementPdf(String providerName, String planName) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: 'SaveNest Service Agreement'),
              pw.Paragraph(text: 'Date: ${DateTime.now().toIso8601String().split('T').first}'),
              pw.SizedBox(height: 20),
              pw.Paragraph(text: 'Customer Information:'),
              pw.Bullet(text: 'Name: ${_nameController.text}'),
              pw.Bullet(text: 'Email: ${_emailController.text}'),
              pw.Bullet(text: 'Phone: ${_phoneController.text}'),
              pw.SizedBox(height: 20),
              pw.Paragraph(text: 'Service Details:'),
              pw.Bullet(text: 'New Provider: $providerName'),
              pw.Bullet(text: 'Plan Name: $planName'),
              pw.SizedBox(height: 20),
              pw.Paragraph(text: 'Terms of Agreement:'),
              pw.Paragraph(text: 'By signing this agreement, the customer authorizes SaveNest to act on their behalf to switch their specified utility service to the new provider and plan detailed above. SaveNest is authorized to contact the current and new providers to facilitate this transition.'),
              pw.Paragraph(text: 'Customer acknowledges that they have read and agree to SaveNest\'s full Terms of Service and Privacy Policy.'),
              pw.SizedBox(height: 40),
              pw.Paragraph(text: 'Signature:'),
              pw.Paragraph(text: 'Electronically signed and agreed to by ${_nameController.text}.'),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _submitSwitch(String providerName, String planName) async {
    if (!_hasAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must agree to the Terms of Service to proceed.'), backgroundColor: Colors.red));
      return;
    }
    
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all contact details in Step 1.'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSwitching = true);
    
    try {
      final pdfBytes = await _generateAgreementPdf(providerName, planName);
      final result = await _hubSpotService.submitConciergeAgreement(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        dealProvider: providerName,
        dealPlan: planName,
        pdfBytes: pdfBytes,
      );

      if (mounted) {
        if (result['success'] == true) {
          setState(() { _isSwitching = false; _currentStep = 4; });
        } else {
          setState(() => _isSwitching = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${result['message']}'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSwitching = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to switch: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all contact details.'), backgroundColor: Colors.red));
        return;
      }
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      final providerName = widget.deal?.providerName ?? 'your new provider';
      final planName = widget.deal?.planName ?? 'the selected plan';
      _submitSwitch(providerName, planName);
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
              child: Column(
                children: [
                  Padding(
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
                  const ModernFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWizard() {
    final providerName = widget.deal?.providerName ?? 'your new provider';
    final planName = widget.deal?.planName ?? 'the selected plan';
    final isEnergy = widget.deal?.category == ProductCategory.electricity || widget.deal?.category == ProductCategory.gas;

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
          title: const Text('Contact Details', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            children: [
              const Text('Please provide your details so we can process your application and contact you.'),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
              ),
            ],
          ),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text('Authorize SaveNest', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Provide authorization for us to act on your behalf to cancel your old plan and set up the new one.'),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('I agree to the Terms of Service and authorize SaveNest to electronically sign and submit the service agreement on my behalf.', style: TextStyle(fontSize: 14)),
                value: _hasAgreed,
                onChanged: (val) {
                  setState(() {
                    _hasAgreed = val ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppTheme.vibrantEmerald,
              ),
            ],
          ),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: Text(isEnergy ? 'Smart Meter Sync' : 'Service Verification', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(isEnergy 
            ? 'Connecting to your smart meter to ensure the new tariff perfectly matches your exact usage profile.'
            : 'Verifying service connection and availability details for $providerName.'),
          isActive: _currentStep >= 2,
        ),
        Step(
          title: const Text('Final Review', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('You are switching to $providerName - $planName. An official service agreement PDF will be generated and uploaded upon clicking Confirm.'),
          isActive: _currentStep >= 3,
        ),
      ],
    );
  }
}
