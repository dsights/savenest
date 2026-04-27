import 'package:flutter/material.dart';

enum SortMode { defaultSort, priceAsc, priceDesc, ratingDesc }

enum ProductCategory {
  electricity,
  gas,
  internet,
  mobile,
  insurance,
  creditCards,
  solar,
  security
}

class Deal {
  final String id;
  final ProductCategory category;
  final String providerName;
  final String providerLogoUrl; // Asset path or Network URL
  final Color providerColor; // Fallback if logo fails
  final String planName;
  final String description;
  final List<String> keyFeatures;
  
  // Pricing
  final double price; // Monthly cost or estimated cost
  final String priceUnit; // "/mo", "/qtr", " est."
  
  // Affiliate Data
  final String affiliateUrl; // The tracking link

  // Ranking
  final double rating; // 0.0 to 5.0
  final bool isSponsored; // To pin to top
  final bool isGreen; // specific for Energy
  final bool isEnabled; // New: To hide deals with missing data (e.g. price)
  final List<String> applicableStates; // New: To filter by region (NSW, VIC, etc.)
  final Map<String, String> details; // New: For all other meaningful data

  const Deal({
    required this.id,
    required this.category,
    required this.providerName,
    this.providerLogoUrl = '',
    required this.providerColor,
    required this.planName,
    required this.description,
    required this.keyFeatures,
    required this.price,
    this.priceUnit = '/mo',
    required this.affiliateUrl,
    this.rating = 0.0,
    this.isSponsored = false,
    this.isGreen = false,
    this.isEnabled = true,
    this.applicableStates = const [],
    this.details = const {},
  });

  // Weighted value score: 60% price efficiency, 20% rating, 20% feature richness.
  // This matches the ranking methodology stated to users on the comparison screen.
  double get valueScore {
    const maxPrice = 300.0;
    final priceScore = price > 0 ? (1.0 - (price / maxPrice).clamp(0.0, 1.0)) : 0.5;
    final ratingScore = rating / 5.0;
    final featureScore = (keyFeatures.length / 10.0).clamp(0.0, 1.0);
    return (priceScore * 0.6) + (ratingScore * 0.2) + (featureScore * 0.2);
  }
}