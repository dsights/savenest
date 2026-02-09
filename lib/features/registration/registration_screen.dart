import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../savings/savings_provider.dart';
import '../../services/hubspot_service.dart';
import '../comparison/comparison_screen.dart';

import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // State for Switch Selection and Images
  // Map of UtilityType -> boolean (is selected)
  final Map<UtilityType, bool> _selectedServices = {};
  // Map of UtilityType -> XFile (image)
  final Map<UtilityType, XFile?> _billImages = {};
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize selected services based on what has value in the controller
    // We defer this to build or post-frame callback usually, but for simple init:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final costs = ref.read(savingsControllerProvider);
      setState(() {
        if (costs.nbn > 0) _selectedServices[UtilityType.nbn] = true;
        if (costs.electricity > 0) _selectedServices[UtilityType.electricity] = true;
        if (costs.gas > 0) _selectedServices[UtilityType.gas] = true;
        if (costs.mobile > 0) _selectedServices[UtilityType.mobile] = true;
        if (costs.homeInsurance > 0) _selectedServices[UtilityType.homeInsurance] = true;
        if (costs.carInsurance > 0) _selectedServices[UtilityType.carInsurance] = true;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(UtilityType type) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _billImages[type] = image;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final totalSavings = ref.read(totalAnnualSavingsProvider);
      
      // Filter selected services
      final servicesList = _selectedServices.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key.name)
          .toList();

      final hubSpotService = HubSpotService();
      final result = await hubSpotService.submitForm(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        totalSavings: totalSavings,
        services: servicesList,
        billImages: _billImages,
      );

      setState(() => _isSubmitting = false);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: AppTheme.vibrantEmerald,
            ),
          );
          // Navigate to Comparison Engine
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ComparisonScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show utilities that have been entered in the previous screen (value > 0)
    final costs = ref.watch(savingsControllerProvider);
    final validUtilities = <UtilityType>[];
    if (costs.nbn > 0) validUtilities.add(UtilityType.nbn);
    if (costs.electricity > 0) validUtilities.add(UtilityType.electricity);
    if (costs.gas > 0) validUtilities.add(UtilityType.gas);
    if (costs.mobile > 0) validUtilities.add(UtilityType.mobile);
    if (costs.homeInsurance > 0) validUtilities.add(UtilityType.homeInsurance);
    if (costs.carInsurance > 0) validUtilities.add(UtilityType.carInsurance);

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      endDrawer: const MainMobileDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainBackgroundGradient,
        ),
        child: Column(
          children: [
            const MainNavigationBar(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.vibrantEmerald,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildGlassTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 12),
                          _buildGlassTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          _buildGlassTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                          
                          const SizedBox(height: 32),
                          const Text(
                            'Selected Services',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.vibrantEmerald,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Upload a bill photo to expedite the switch.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
        
                          if (validUtilities.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text('No services selected. Go back to calculate savings.'),
                            )
                          else
                            ...validUtilities.map((type) => _buildServiceItem(type)),
        
                          const SizedBox(height: 40),
                          
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.vibrantEmerald,
                                foregroundColor: AppTheme.deepNavy,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: AppTheme.deepNavy),
                                    )
                                  : const Text(
                                      'CONFIRM SWITCH',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 12,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: AppTheme.vibrantEmerald),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter your $label';
          }
          
          final trimmedValue = value.trim();

          if (label.contains('Email')) {
            // Strict email validation: user@domain.tld
            final emailRegex = RegExp(
              r'^[a-zA-Z0-9.!#$%&' r"'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
            );
            if (!emailRegex.hasMatch(trimmedValue)) {
              return 'Enter a valid email (e.g. name@example.com)';
            }
          }
          
          if (label.contains('Phone')) {
            // Phone validation: only digits, spaces, dashes, plus. Min 9 digits.
            final cleanPhone = trimmedValue.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
            if (cleanPhone.length < 9) {
              return 'Phone number must be at least 9 digits';
            }
            if (!RegExp(r'^[0-9]+$').hasMatch(cleanPhone)) {
              return 'Phone number can only contain digits';
            }
          }

          if (label.contains('Name')) {
             if (trimmedValue.split(' ').length < 2) {
               return 'Please enter your full name (First and Last)';
             }
          }

          return null;
        },
      ),
    );
  }

  Widget _buildServiceItem(UtilityType type) {
    final name = type.name.toUpperCase();
    final isSelected = _selectedServices[type] ?? false;
    final imageFile = _billImages[type];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        borderRadius: 12,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  activeColor: AppTheme.vibrantEmerald,
                  checkColor: AppTheme.deepNavy,
                  side: const BorderSide(color: Colors.white54),
                  onChanged: (val) {
                    setState(() {
                      _selectedServices[type] = val ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isSelected)
                  InkWell(
                    onTap: () => _pickImage(type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: imageFile != null 
                              ? AppTheme.vibrantEmerald 
                              : Colors.white30,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            imageFile != null ? Icons.check_circle : Icons.camera_alt,
                            size: 18,
                            color: imageFile != null 
                                ? AppTheme.vibrantEmerald 
                                : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            imageFile != null ? 'Added' : 'Add Bill',
                            style: TextStyle(
                              fontSize: 12,
                              color: imageFile != null 
                                  ? AppTheme.vibrantEmerald 
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected && imageFile != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 48), // Indent to align with text
                  Expanded(
                    child: Text(
                      'Image selected: ${imageFile.name}',
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}