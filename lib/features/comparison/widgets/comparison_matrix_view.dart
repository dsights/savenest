import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../comparison_model.dart';
import 'package:go_router/go_router.dart';

class ComparisonMatrixView extends StatelessWidget {
  final List<Deal> deals;

  const ComparisonMatrixView({super.key, required this.deals});

  @override
  Widget build(BuildContext context) {
    if (deals.isEmpty) return const Center(child: Text('No deals to compare'));
    
    final topDeals = deals.take(4).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppTheme.deepNavy),
            dataRowMaxHeight: double.infinity,
            dataRowMinHeight: 60,
            columnSpacing: 30,
            columns: [
              const DataColumn(label: Text('Feature', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ...topDeals.map((d) => DataColumn(
                label: Flexible(
                  child: Text(d.providerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                ),
              )),
            ],
            rows: [
              DataRow(cells: [
                const DataCell(Text('Plan Name', style: TextStyle(fontWeight: FontWeight.bold))),
                ...topDeals.map((d) => DataCell(Text(d.planName, style: const TextStyle(fontSize: 13)))),
              ]),
              DataRow(cells: [
                const DataCell(Text('Estimated Price', style: TextStyle(fontWeight: FontWeight.bold))),
                ...topDeals.map((d) => DataCell(Text('\$${d.price.toStringAsFixed(2)} ${d.priceUnit}', style: const TextStyle(color: AppTheme.vibrantEmerald, fontWeight: FontWeight.bold, fontSize: 16)))),
              ]),
              DataRow(cells: [
                const DataCell(Text('Key Features', style: TextStyle(fontWeight: FontWeight.bold))),
                ...topDeals.map((d) => DataCell(Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: d.keyFeatures.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text('• $f', style: const TextStyle(fontSize: 12)),
                    )).toList(),
                  ),
                ))),
              ]),
              DataRow(cells: [
                const DataCell(Text('Rating', style: TextStyle(fontWeight: FontWeight.bold))),
                ...topDeals.map((d) => DataCell(Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' ${d.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ))),
              ]),
              DataRow(cells: [
                const DataCell(Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                ...topDeals.map((d) => DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () => context.push('/concierge', extra: d),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentOrange, foregroundColor: Colors.white),
                      child: const Text('1-Click Switch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  )
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
