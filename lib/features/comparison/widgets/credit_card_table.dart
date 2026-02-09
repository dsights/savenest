import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../credit_card_model.dart';
import '../../../../theme/app_theme.dart';

class CreditCardTable extends StatelessWidget {
  final List<CreditCardDeal> deals;

  const CreditCardTable({super.key, required this.deals});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.grey[300],
            dataTableTheme: DataTableThemeData(
              headingRowColor: MaterialStateProperty.all(AppTheme.deepNavy),
              headingTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return AppTheme.vibrantEmerald.withOpacity(0.1);
                  }
                  return Colors.white; // Default color
                },
              ),
            ),
          ),
          child: DataTable(
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('Issuer')),
              DataColumn(label: Text('Card Name')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Annual Fee')),
              DataColumn(label: Text('Purchase APR')),
              DataColumn(label: Text('Bonus')),
              DataColumn(label: Text('Rewards')),
              DataColumn(label: Text('Interest Free')),
              DataColumn(label: Text('Foreign TX Fee')),
              DataColumn(label: Text('Action')),
            ],
            rows: deals.map((deal) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Placeholder for logo if we had a proper image loader for these URLs
                        // Since URLs are placeholders in CSV, we assume text or basic icon
                         const Icon(Icons.credit_card, size: 20, color: AppTheme.deepNavy),
                        const SizedBox(width: 8),
                        Text(deal.issuer, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  DataCell(Text(deal.cardName)),
                  DataCell(Text(deal.cardType)),
                  DataCell(Text(deal.annualFee)),
                  DataCell(Text(deal.purchaseApr)),
                  DataCell(Text(deal.signUpBonus)),
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Text(
                        deal.rewardsProgram,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                   DataCell(Text(deal.interestFreeDays)),
                  DataCell(Text(deal.foreignTxFee)),
                  DataCell(
                    ElevatedButton(
                      onPressed: () {
                         // Use PDS link or generic apply
                         final url = deal.directPdsLink;
                         if (url.isNotEmpty) {
                           launchUrl(Uri.parse(url));
                         }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.vibrantEmerald,
                        foregroundColor: AppTheme.deepNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Details'),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
