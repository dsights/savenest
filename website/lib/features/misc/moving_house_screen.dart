import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';
import '../home/widgets/modern_footer.dart';

class MovingHouseScreen extends StatelessWidget {
  const MovingHouseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: SingleChildScrollView(
        primary: true,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: [
            const MainNavigationBar(),
            _buildHero(context),
            _buildIntroSection(context),
            _buildStepsSection(context),
            _buildChecklistSection(context),
            _buildStateFeesSection(context),
            _buildFAQSection(context),
            const ModernFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: AppTheme.mainBackgroundGradient,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ENERGY GUIDE',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Moving House? Connect Your Energy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.deepNavy,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Everything you need to know about connecting electricity and gas at your new home.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.slate600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/deals/electricity'),
                child: const Text('Compare Energy Plans'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Moving house is stressful enough without worrying about your utilities. At SaveNest, we help you find the right energy plan for your new home so you can move in with the lights on.',
                style: TextStyle(fontSize: 18, height: 1.6, color: AppTheme.deepNavy),
              ),
              const SizedBox(height: 32),
              const Text(
                'Why Compare Energy Before You Move?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
              ),
              const SizedBox(height: 16),
              _bulletItem('Save Money: Your new home might be in a different distribution zone with different rates.'),
              _bulletItem('Avoid Fees: Standard connection fees apply, but choosing the right retailer can help minimize total costs.'),
              _bulletItem('Eco-Friendly Options: Moving is a great time to switch to a 100% GreenPower plan.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              const Text(
                'How to Connect Energy When Moving',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
              ),
              const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _stepItem('1', 'Notify Your Retailer', 'Contact your current provider at least 3 business days before you move.'),
                  _stepItem('2', 'Compare Plans', 'Use SaveNest to find the best value plan for your new address.'),
                  _stepItem('3', 'Book Connection', 'Confirm your move-in date and ensure clear access to the meter.'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.05),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Moving House Checklist',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
              ),
              const SizedBox(height: 24),
              _checkItem('Book your move at least 2 weeks in advance.'),
              _checkItem('Notify your current energy retailer of your move-out date.'),
              _checkItem('Compare energy plans for your new address on SaveNest.'),
              _checkItem('Arrange a final meter reading for your old property.'),
              _checkItem('Ensure the main switch is OFF at your new home on connection day.'),
              _checkItem('Update your address for other services (internet, insurance, etc.).'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.check_box_outlined, color: AppTheme.primaryBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, color: AppTheme.deepNavy))),
        ],
      ),
    );
  }

  Widget _buildStateFeesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              const Text(
                'Typical Connection & Disconnection Fees',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fees are set by the distributor in your area and passed through by your retailer. Prices are estimates for standard business-day requests.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.slate600),
              ),
              const SizedBox(height: 40),
              _buildFeeTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeTable() {
    return Table(
      border: TableBorder.all(color: AppTheme.slate300),
      children: [
        const TableRow(
          decoration: BoxDecoration(color: AppTheme.deepNavy),
          children: [
            _TableCell('State', isHeader: true),
            _TableCell('Electricity Connection', isHeader: true),
            _TableCell('Gas Connection', isHeader: true),
          ],
        ),
        _feeRow('NSW', '\$12 - \$90', '\$10 - \$60'),
        _feeRow('VIC', '\$10 - \$55', '\$10 - \$50'),
        _feeRow('QLD', '\$10 - \$60', '\$10 - \$55'),
        _feeRow('SA', '\$12 - \$50', '\$10 - \$45'),
      ],
    );
  }

  TableRow _feeRow(String state, String elec, String gas) {
    return TableRow(
      children: [
        _TableCell(state),
        _TableCell(elec),
        _TableCell(gas),
      ],
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
              ),
              const SizedBox(height: 40),
              _faqItem('How much notice do I need to give?', 'Most retailers require at least 3 business days notice to arrange a final meter reading and connection at your new home.'),
              _faqItem('Will I be charged for a final meter reading?', 'Yes, usually there is a small fee for the distributor to perform a final reading at your old address.'),
              _faqItem('What if there is life support equipment?', 'You must notify your retailer immediately. Connections for life support customers are prioritized and require specific forms.'),
              _faqItem('Can I keep my current plan?', 'Usually yes, if your current retailer operates in your new area. However, it is a great time to compare and see if a better deal is available.'),
              _faqItem('Do I need to be home for the connection?', 'Generally no, as long as the technician has clear and safe access to the electricity or gas meter.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppTheme.vibrantEmerald, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, color: AppTheme.slate600))),
        ],
      ),
    );
  }

  Widget _stepItem(String number, String title, String desc) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(color: AppTheme.accentOrange, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.deepNavy)),
            const SizedBox(height: 8),
            Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.slate600)),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.deepNavy)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(color: AppTheme.slate600, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _TableCell(this.text, {this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader ? Colors.white : AppTheme.deepNavy,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
