import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/main_mobile_drawer.dart';
import '../home/widgets/modern_footer.dart';

class SavingsDashboardScreen extends StatelessWidget {
  const SavingsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      endDrawer: const MainMobileDrawer(),
      body: Column(
        children: [
          const MainNavigationBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Savings Dashboard',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Track your progress, earn badges, and join the community.',
                        style: TextStyle(fontSize: 16, color: AppTheme.slate600),
                      ),
                      const SizedBox(height: 32),
                      
                      // Stats Row
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          _buildStatCard('Lifetime Savings', '\$1,240', Icons.savings, AppTheme.vibrantEmerald),
                          _buildStatCard('Active Plans', '3', Icons.bolt, AppTheme.primaryBlue),
                          _buildStatCard('Referral Earnings', '\$150', Icons.group_add, AppTheme.accentOrange),
                        ],
                      ),
                      const SizedBox(height: 40),
                      
                      // Advanced Integrations Row
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          // Smart Meter Dashboard
                          Container(
                            width: 400,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.slate300.withOpacity(0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.smart_screen, color: AppTheme.primaryBlue),
                                    SizedBox(width: 8),
                                    Text('Smart Meter Integration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.deepNavy)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text('Live Usage: 1.2 kW (Currently in Off-Peak)', style: TextStyle(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                const Text('Connected to NMI: 4100XXXXXX', style: TextStyle(fontSize: 12, color: AppTheme.slate600)),
                                const SizedBox(height: 16),
                                LinearProgressIndicator(value: 0.3, backgroundColor: Colors.grey.shade200, color: AppTheme.primaryBlue, minHeight: 8),
                                const SizedBox(height: 8),
                                const Text('30% of daily average reached.', style: TextStyle(fontSize: 12, color: AppTheme.slate600)),
                              ],
                            ),
                          ),
                          
                          // Predictive Analytics
                          Container(
                            width: 400,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.slate300.withOpacity(0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.trending_down, color: AppTheme.accentOrange),
                                    SizedBox(width: 8),
                                    Text('Predictive Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.deepNavy)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text('Electricity prices in VIC are expected to drop by 4% next quarter.', style: TextStyle(color: AppTheme.slate600)),
                                const SizedBox(height: 16),
                                Container(
                                  height: 80,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [AppTheme.primaryBlue.withOpacity(0.1), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(child: Text('📊 Chart Data Placeholder', style: TextStyle(color: AppTheme.primaryBlue))),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Savings Projection Timeline
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.deepNavy,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimated Savings Projection', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('Based on your current plan switches and optimization.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildTimelineItem('1 Year', '\$1,240', AppTheme.vibrantEmerald),
                                _buildTimelineItem('3 Years', '\$3,720', AppTheme.accentOrange),
                                _buildTimelineItem('5 Years', '\$6,200', Colors.white),
                              ],
                            ),
                            const SizedBox(height: 32),
                            const Center(
                              child: Text(
                                'You are currently in the top 5% of savers in your region!',
                                style: TextStyle(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Carbon Footprint Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade900]),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Your Carbon Impact', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  Text('By switching to Green energy plans, you have reduced your household emissions by 2.4 tonnes of CO2 per year.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                              child: const Column(
                                children: [
                                  Icon(Icons.eco, color: Colors.white, size: 32),
                                  SizedBox(height: 8),
                                  Text('-2.4t', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                  Text('CO2 / year', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Badges Section
                      const Text('Achievements', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.deepNavy)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildBadge('Eco Warrior', 'Switched to 100% Green Energy', Icons.eco, Colors.green),
                          _buildBadge('Smart Saver', 'Saved over \$500', Icons.emoji_events, Colors.amber),
                          _buildBadge('Early Adopter', 'Joined SaveNest in 2026', Icons.rocket_launch, Colors.purple),
                        ],
                      ),
                      
                      const SizedBox(height: 40),

                      // Community
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.slate300.withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Community Insights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.deepNavy)),
                            const SizedBox(height: 16),
                            _buildCommunityPost('Sarah from NSW', 'Just saved \$800 on my energy bill by switching to AGL. The comparison tool is amazing!', '2 hours ago'),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Divider(height: 1),
                            ),
                            _buildCommunityPost('Mark from VIC', 'Does anyone recommend a good NBN provider for gaming?', '5 hours ago'),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                              child: const Text('Join the Discussion', style: TextStyle(fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ),
                      
                            const SizedBox(height: 60),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.slate600)),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildBadge(String title, String desc, IconData icon, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          CircleAvatar(backgroundColor: color, radius: 24, child: Icon(icon, color: Colors.white, size: 24)),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color.withOpacity(0.8), fontSize: 16)),
          const SizedBox(height: 4),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppTheme.slate600)),
        ],
      ),
    );
  }

  Widget _buildCommunityPost(String author, String content, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(backgroundColor: AppTheme.slate300, child: Text(author[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(author, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.deepNavy)),
                  const SizedBox(width: 8),
                  Text(time, style: const TextStyle(fontSize: 12, color: AppTheme.slate600)),
                ],
              ),
              const SizedBox(height: 40),
              Text(content, style: const TextStyle(color: AppTheme.slate600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String period, String amount, Color color) {
    return Column(
      children: [
        Text(period, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Text(amount, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }
}
