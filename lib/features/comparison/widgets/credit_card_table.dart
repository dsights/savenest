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
    const headerTextStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

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
                child: Row(
                  children: const [
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
    // Generate potential filename from issuer name
    // e.g. "Teachers Mutual" -> "teachers_mutual"
    // Try .png first, then .ico (Flutter handles both via Image.asset but we need to know what we have)
    // Since we don't know exactly what downloaded successfully without checking file existence (which is async or requires loading), 
    // and we have a mix of .ico and .png, we can try to guess or use a smarter Image provider that tries one then the other?
    // Or just use the SafeName logic we used in the script.
    
    final safeName = deal.issuer.toLowerCase().replaceAll(' ', '_').replaceAll('&', 'and');
    // Note: We downloaded some as .png and some as .ico.
    // Ideally we would standardize. For now, let's try to load .png, if fails (visually), fallback?
    // Actually, `Image.asset` will throw if not found in manifest? No, it just won't show.
    // But we added `assets/images/logos/` to pubspec, so all files in there are included.
    
    // We can't easily check "if asset exists" synchronously in build without loading Manifest.
    // So we will try to rely on the fact that we downloaded most of them.
    // Let's assume .png for the google ones and .ico for the originals.
    // The script logic was: if url ends in .png -> .png, else .ico.
    // AND the google favicon script saved as .png.
    
    // Most manually downloaded are .ico (first script)
    // Most missing ones (second script) are .png.
    
    // Heuristic:
    // Teachers Mutual -> .png
    // St George -> .png
    // IMB -> .png
    // BankSA -> .png
    // DiviPay -> .png
    // P&N -> .png
    // Newcastle -> .png
    // Bank of Melb -> .png
    // Judo -> .png
    // HSBC -> .png
    //
    // Amex -> .ico
    // ANZ -> .ico
    // Bankwest -> .ico
    // CBA -> .ico
    // Citibank -> .ico
    // Coles -> .ico
    // Great Southern -> .ico
    // Kogan -> .ico
    // MyState -> .ico
    // Police -> .ico
    // Suncorp -> .ico
    // Virgin -> .ico
    // Westpac -> .ico
    // Woolworths -> .ico
    // Airwallex -> .ico
    
    String assetPath;
    final pngIssuers = [
      'teachers_mutual', 'st_george', 'imb_bank', 'banksa', 'divipay', 'p_and_n_bank',
      'newcastle_permanent', 'bank_of_melbourne', 'judo_bank', 'hsbc'
    ];
    
    if (pngIssuers.contains(safeName)) {
      assetPath = 'assets/images/logos/$safeName.png';
    } else {
      assetPath = 'assets/images/logos/$safeName.ico';
    }

    return Container(
      width: width,
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: Image.asset(
        assetPath,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to text if asset missing
          return Text(
            deal.issuer,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.deepNavy),
            textAlign: TextAlign.center,
          );
        },
      ),
    );
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