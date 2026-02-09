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
      controller: _verticalController,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        controller: _verticalController,
        scrollDirection: Axis.vertical,
        child: Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          trackVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.grey[300],
                dataTableTheme: DataTableThemeData(
                  headingRowColor: MaterialStateProperty.all(AppTheme.deepNavy),
                  headingTextStyle: headerTextStyle,
                  dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      return Colors.white; // White background for rows
                    },
                  ),
                ),
              ),
              child: DataTable(
                columnSpacing: 24,
                headingRowHeight: 56,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 80, // Allow more height for wrapping text
                columns: const [
                  DataColumn(label: Text('Issuer')),
                  DataColumn(label: Text('Action')), // Moved to 2nd column
                  DataColumn(label: Text('Card Name')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Annual Fee')),
                  DataColumn(label: Text('Purchase APR')),
                  DataColumn(label: Text('Bonus')),
                  DataColumn(label: Text('Rewards')),
                  DataColumn(label: Text('Interest Free')),
                  DataColumn(label: Text('Foreign TX Fee')),
                ],
                rows: widget.deals.map((deal) {
                  return DataRow(
                    cells: [
                      DataCell(
                        deal.logoLink.isNotEmpty
                            ? Image.network(
                                deal.logoLink,
                                width: 60,
                                height: 40,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    deal.issuer,
                                    style: contentTextStyle.copyWith(fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
                                  );
                                },
                              )
                            : Text(
                                deal.issuer,
                                style: contentTextStyle.copyWith(fontWeight: FontWeight.bold, color: AppTheme.deepNavy),
                              ),
                      ),
                      DataCell( // Moved Action button here
                        ElevatedButton(
                          onPressed: () {
                             final url = deal.directPdsLink;
                             if (url.isNotEmpty) {
                               launchUrl(Uri.parse(url));
                             }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.vibrantEmerald,
                            foregroundColor: AppTheme.deepNavy,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 32), // Compact button
                          ),
                          child: const Text('Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: Text(
                            deal.cardName,
                            style: contentTextStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(deal.cardType, style: contentTextStyle)),
                      DataCell(Text(deal.annualFee, style: contentTextStyle.copyWith(fontWeight: FontWeight.bold))),
                      DataCell(Text(deal.purchaseApr, style: contentTextStyle)),
                      DataCell(
                         SizedBox(
                          width: 100,
                          child: Text(
                            deal.signUpBonus,
                            style: contentTextStyle.copyWith(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold),
                             maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 150,
                          child: Text(
                            deal.rewardsProgram,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: contentTextStyle.copyWith(fontSize: 12),
                          ),
                        ),
                      ),
                       DataCell(Text(deal.interestFreeDays, style: contentTextStyle)),
                      DataCell(Text(deal.foreignTxFee, style: contentTextStyle)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
