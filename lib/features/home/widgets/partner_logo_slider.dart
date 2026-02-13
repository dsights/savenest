import 'package:flutter/material.dart';
import 'dart:async';
import '../../../theme/app_theme.dart';

class PartnerLogoSlider extends StatefulWidget {
  const PartnerLogoSlider({super.key});

  @override
  State<PartnerLogoSlider> createState() => _PartnerLogoSliderState();
}

class _PartnerLogoSliderState extends State<PartnerLogoSlider> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  
  final List<String> _logos = [
    'assets/images/logos/westpac.ico',
    'assets/images/logos/cba.ico',
    'assets/images/logos/anz.ico',
    'assets/images/logos/st_george.png',
    'assets/images/logos/bankwest.ico',
    'assets/images/logos/amex.ico',
    'assets/images/logos/hsbc.png',
    'assets/images/logos/suncorp.ico',
    'assets/images/logos/woolworths.ico',
    'assets/images/logos/coles.ico',
    'assets/images/logos/kogan.ico',
    'assets/images/logos/airwallex.ico',
    'assets/images/logos/citibank.ico',
    'assets/images/logos/bank_of_melbourne.png',
    'assets/images/logos/banksa.png',
    'assets/images/logos/great_southern_bank.ico',
    'assets/images/logos/mystate_bank.ico',
    'assets/images/logos/police_bank.ico',
    'assets/images/logos/virgin_money.ico',
    'assets/images/logos/divipay.png',
    'assets/images/logos/imb_bank.png',
    'assets/images/logos/judo_bank.png',
    'assets/images/logos/newcastle_permanent.png',
    'assets/images/logos/pandn_bank.png',
    'assets/images/logos/teachers_mutual.png',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients) {
        if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            _scrollController.offset + 1,
            duration: const Duration(milliseconds: 30),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Text(
            "We compare brands you know and trust",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.slate600,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 60,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _logos.length * 2, // Double for seamless loop
              itemBuilder: (context, index) {
                final logoPath = _logos[index % _logos.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Image.asset(
                    logoPath,
                    height: 50,
                    width: 100,
                    fit: BoxFit.contain,
                    // Use a color filter to make them look uniform if needed, 
                    // but usually color logos are better for trust.
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      alignment: Alignment.center,
                      child: Text(
                        logoPath.split('/').last.split('.').first.toUpperCase(),
                        style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
