import 'dart:convert';
import 'package:flutter/services.dart';
import '../comparison_model.dart';

abstract class ProductRepository {
  Future<List<Deal>> getDeals(ProductCategory category);
  Future<Deal?> getDealById(String id);
}

class JsonProductRepository implements ProductRepository {
  
  // Cache the data so we don't read the file every time
  Map<String, dynamic>? _cachedData;

  Future<void> _loadData() async {
    if (_cachedData != null) return;
    
    // In a real app, this would be: await http.get(Uri.parse('https://api.savenest.com/deals'));
    final jsonString = await rootBundle.loadString('assets/data/products.json');
    _cachedData = json.decode(jsonString);
  }

  @override
  Future<List<Deal>> getDeals(ProductCategory category) async {
    await _loadData();
    
    final categoryKey = _getCategoryKey(category);
    final List<dynamic> rawList = _cachedData?[categoryKey] ?? [];

    return rawList.map((json) => _fromJson(json, category)).toList();
  }

  @override
  Future<Deal?> getDealById(String id) async {
    await _loadData();
    if (_cachedData == null) return null;

    for (var category in ProductCategory.values) {
      if (category == ProductCategory.creditCards) continue; // Skip credit cards for now as they use a different model
      final key = _getCategoryKey(category);
      if (_cachedData!.containsKey(key)) {
        final List<dynamic> list = _cachedData![key];
        for (var json in list) {
          if (json['id'] == id) {
            return _fromJson(json, category);
          }
        }
      }
    }
    return null;
  }

  String _getCategoryKey(ProductCategory category) {
    switch (category) {
      case ProductCategory.electricity: return 'electricity';
      case ProductCategory.gas: return 'gas';
      case ProductCategory.mobile: return 'mobile';
      case ProductCategory.internet: return 'internet';
      case ProductCategory.insurance: return 'insurance';
      default: return 'other';
    }
  }

  double _parseCommission(String commission) {
    if (commission.toLowerCase().contains('pending')) return 0.0;
    if (commission.toLowerCase().contains('varies')) return 0.0;
    
    try {
      // Extract numbers from string like "$8.50 per sale"
      final numericPart = commission.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.parse(numericPart);
    } catch (e) {
      return 0.0;
    }
  }

  Deal _fromJson(Map<String, dynamic> json, ProductCategory category) {
    return Deal(
      id: json['id'],
      category: category,
      providerName: json['providerName'],
      providerLogoUrl: json['logoUrl'] ?? '',
      providerColor: Color(int.parse(json['providerColor'])), // Parse hex string
      planName: json['planName'],
      description: json['description'],
      keyFeatures: List<String>.from(json['keyFeatures']),
      price: (json['price'] as num).toDouble(),
      priceUnit: json['priceUnit'] ?? '/mo',
      affiliateUrl: json['affiliateUrl'],
      commission: _parseCommission(json['commission']),
      rating: (json['rating'] as num).toDouble(),
      isSponsored: json['isSponsored'] ?? false,
      isGreen: json['isGreen'] ?? false,
    );
  }
}