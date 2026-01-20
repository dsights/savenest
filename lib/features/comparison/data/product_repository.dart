import 'dart:convert';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:flutter/material.dart';
import '../comparison_model.dart';

abstract class ProductRepository {
  Future<List<Deal>> getDeals(ProductCategory category);
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

  String _getCategoryKey(ProductCategory category) {
    switch (category) {
      case ProductCategory.energy: return 'energy';
      case ProductCategory.internet: return 'internet';
      case ProductCategory.mobile: return 'mobile';
      case ProductCategory.homeInsurance: return 'homeInsurance';
      default: return 'other';
    }
  }

  Deal _fromJson(Map<String, dynamic> json, ProductCategory category) {
    return Deal(
      id: json['id'],
      category: category,
      providerName: json['providerName'],
      providerColor: Color(int.parse(json['providerColor'])), // Parse hex string
      planName: json['planName'],
      description: json['description'],
      keyFeatures: List<String>.from(json['keyFeatures']),
      price: (json['price'] as num).toDouble(),
      priceUnit: json['priceUnit'] ?? '/mo',
      affiliateUrl: json['affiliateUrl'],
      rating: (json['rating'] as num).toDouble(),
      isSponsored: json['isSponsored'] ?? false,
      isGreen: json['isGreen'] ?? false,
    );
  }
}