import 'package:flutter/material.dart';

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
  final double commission; // Internal use: projected revenue
  
  // Ranking
  final double rating; // 0.0 to 5.0
  final bool isSponsored; // To pin to top
  final bool isGreen; // specific for Energy

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
    this.commission = 0.0,
    this.rating = 0.0,
    this.isSponsored = false,
    this.isGreen = false,
  });
}