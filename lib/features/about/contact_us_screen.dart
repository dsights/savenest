import 'package:flutter/material.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:savenest/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';
import '../../widgets/page_hero.dart';
import '../home/widgets/modern_footer.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSuccess = true;
        });
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      MetaSEO meta = MetaSEO();
      const String title = 'Contact Us | SaveNest';
      const String description = 'Get in touch with the SaveNest team. Ask questions, provide feedback, or inquire about partnership opportunities.';
      const String imageUrl = 'https://savenest.au/assets/assets/images/hero_energy.jpg';

      meta.nameContent(name: 'title', content: title);
      meta.nameContent(name: 'description', content: description);
      meta.ogTitle(ogTitle: title);
      meta.ogDescription(ogDescription: description);
      meta.propertyContent(property: 'og:url', content: 'https://savenest.au/contact');
      meta.ogImage(ogImage: imageUrl);
    }

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MainNavigationBar(),
            const PageHero(
              badge: 'Get in Touch',
              title: 'We\'re here to help',
              subtitle: 'Have a question about a deal or want to partner with us? Reach out and our team will get back to you as soon as possible.',
            ),
            const SizedBox(height: 80),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Form
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: _isSuccess
                              ? _buildSuccessMessage()
                              : _buildContactForm(),
                        ),
                      ),
                      
                      const SizedBox(width: 60),
                      
                      // Contact Info
                      if (MediaQuery.of(context).size.width > 900)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildContactInfoItem(
                              Icons.email_outlined,
                              'Email Us',
                              'support@savenest.au',
                              'Our team typically responds within 24 hours.',
                            ),
                            const SizedBox(height: 40),
                            _buildContactInfoItem(
                              Icons.location_on_outlined,
                              'Our Location',
                              'Melbourne, VIC',
                              'Serving Australians nationwide.',
                            ),
                            const SizedBox(height: 40),
                            _buildContactInfoItem(
                              Icons.business_outlined,
                              'Business Inquiries',
                              'partners@savenest.au',
                              'For partnership and advertising opportunities.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
            const ModernFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send us a message',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.deepNavy,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'John Doe',
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'john@example.com',
            ),
            validator: (value) => (value == null || !value.contains('@')) ? 'Please enter a valid email' : null,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _messageController,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'How can we help you?',
              alignLabelWithHint: true,
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'Please enter your message' : null,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              child: _isSubmitting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Submit Message'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: AppTheme.vibrantEmerald, size: 80),
        const SizedBox(height: 24),
        Text(
          'Message Sent!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.deepNavy,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Thank you for reaching out. We have received your message and will get back to you shortly.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.slate600, fontSize: 16),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: () => setState(() => _isSuccess = false),
          child: const Text('Send another message'),
        ),
      ],
    );
  }

  Widget _buildContactInfoItem(IconData icon, String title, String value, String sub) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.deepNavy)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.accentOrange)),
              const SizedBox(height: 4),
              Text(sub, style: const TextStyle(color: AppTheme.slate600, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
