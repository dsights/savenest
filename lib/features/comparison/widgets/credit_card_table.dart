import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../credit_card_model.dart';
import '../../../../theme/app_theme.dart';

class CreditCardTable extends StatefulWidget {
  final List<CreditCardDeal> deals;

  const CreditCardTable({super.key, required this.deals});

  @override
  State<CreditCardTable> createState() => _CreditCardTableState();
}

class _CreditCardTableState extends State<CreditCardTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  // Column Widths
  static const double colIssuer = 80;
  static const double colAction = 100;
  static const double colCardName = 180;
  static const double colType = 100;
  static const double colFee = 100;
  static const double colApr = 100;
  static const double colBonus = 120;
  static const double colRewards = 150;
  static const double colInterest = 120;
  static const double colForeign = 100;

  static const double totalWidth = colIssuer + colAction + colCardName + colType + colFee + colApr + colBonus + colRewards + colInterest + colForeign;

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const contentTextStyle = TextStyle(color: Colors.black87, fontSize: 13);

    return Scrollbar(
      controller: _horizontalController,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sticky Header
              Container(
                height: 56,
                color: AppTheme.deepNavy,
                child: const Row(
                  children: [
                    _HeaderCell(text: 'Issuer', width: colIssuer),
                    _HeaderCell(text: 'Action', width: colAction),
                    _HeaderCell(text: 'Card Name', width: colCardName),
                    _HeaderCell(text: 'Type', width: colType),
                    _HeaderCell(text: 'Annual Fee', width: colFee),
                    _HeaderCell(text: 'APR', width: colApr),
                    _HeaderCell(text: 'Bonus', width: colBonus),
                    _HeaderCell(text: 'Rewards', width: colRewards),
                    _HeaderCell(text: 'Interest Free', width: colInterest),
                    _HeaderCell(text: 'Foreign Fee', width: colForeign),
                  ],
                ),
              ),
              // Scrollable Body
              Expanded( // Fill remaining vertical space
                child: Scrollbar(
                  controller: _verticalController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalController,
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: widget.deals.map((deal) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(bottom: BorderSide(color: Colors.black12)),
                          ),
                          height: 80, // Fixed row height
                          child: Row(
                            children: [
                              _buildIssuerCell(deal, colIssuer),
                              _buildActionCell(deal, colAction),
                              _TextCell(text: deal.cardName, width: colCardName, style: contentTextStyle, maxLines: 2),
                              _TextCell(text: deal.cardType, width: colType, style: contentTextStyle),
                              _TextCell(text: deal.annualFee, width: colFee, style: contentTextStyle.copyWith(fontWeight: FontWeight.bold)),
                              _TextCell(text: deal.purchaseApr, width: colApr, style: contentTextStyle),
                              _TextCell(text: deal.signUpBonus, width: colBonus, style: contentTextStyle.copyWith(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold), maxLines: 2),
                              _TextCell(text: deal.rewardsProgram, width: colRewards, style: contentTextStyle.copyWith(fontSize: 12), maxLines: 3),
                              _TextCell(text: deal.interestFreeDays, width: colInterest, style: contentTextStyle),
                              _TextCell(text: deal.foreignTxFee, width: colForeign, style: contentTextStyle),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssuerCell(CreditCardDeal deal, double width) {
    final localAsset = _getLocalAssetPath(deal.issuer);

    return Container(
      width: width,
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: localAsset != null
          ? Image.asset(
              localAsset,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => _buildFallbackText(deal.issuer),
            )
          : _buildFallbackText(deal.issuer),
    );
  }

  Widget _buildFallbackText(String issuer) {
    return Text(
      issuer,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.deepNavy),
      textAlign: TextAlign.center,
    );
  }

  String? _getLocalAssetPath(String issuer) {
    final name = issuer.toLowerCase().replaceAll(' ', '').replaceAll('&', 'and');
    
    if (name.contains('origin')) return 'assets/images/logos/origin_energy.png';
    if (name.contains('energyaustralia')) return 'assets/images/logos/energyaustralia.jpg';
    if (name.contains('agl')) return 'assets/images/logos/agl.png';
    if (name.contains('ovo')) return 'assets/images/logos/ovo_energy.png';
    if (name.contains('globird')) return 'assets/images/logos/globird_energy.png';
    if (name.contains('amber')) return 'assets/images/logos/amber_electric.jpg';
    if (name.contains('dodo')) return 'assets/images/logos/dodo.png';
    if (name.contains('kogan')) return 'assets/images/logos/kogan.png';
    if (name.contains('woolworths')) return 'assets/images/logos/woolworths.png';
    if (name.contains('suncorp')) return 'assets/images/logos/suncorp.png';
    if (name.contains('westpac')) return 'assets/images/logos/westpac.png';
    if (name.contains('anz')) return 'assets/images/logos/anz.png';
    if (name.contains('cba')) return 'assets/images/logos/cba.png';
    if (name.contains('commonwealth')) return 'assets/images/logos/cba.png';
    if (name.contains('nab')) return 'assets/images/logos/nab.jpg';
    if (name.contains('airwallex')) return 'assets/images/logos/airwallex.png';
    if (name.contains('volopay')) return 'assets/images/logos/volopay.png';
    if (name.contains('stgeorge')) return 'assets/images/logos/st_george.png';
    if (name.contains('hsbc')) return 'assets/images/logos/hsbc.png';
    if (name.contains('bankwest')) return 'assets/images/logos/bankwest.ico';
    if (name.contains('citibank')) return 'assets/images/logos/citibank.ico';
    if (name.contains('amex')) return 'assets/images/logos/amex.ico';
    if (name.contains('americanexpress')) return 'assets/images/logos/amex.ico';
    
    return null;
  }

  Widget _buildActionCell(CreditCardDeal deal, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          final url = deal.directPdsLink;
          if (url.isNotEmpty) {
            launchUrl(Uri.parse(url));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.vibrantEmerald,
          foregroundColor: AppTheme.deepNavy,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          minimumSize: const Size(0, 30),
          elevation: 0,
        ),
        child: const Text('Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final double width;

  const _HeaderCell({required this.text, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _TextCell extends StatelessWidget {
  final String text;
  final double width;
  final TextStyle style;
  final int maxLines;

  const _TextCell({
    required this.text,
    required this.width,
    required this.style,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}